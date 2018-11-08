//
//  VideoPlayerScreen.swift
//  VLCTest
//
//  Created by rd on 2018/10/12.
//  Copyright © 2018年 rd. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation


enum LinkType : Int {
    case youtube
    case directLink
}

protocol VideoPlayerScreenDelegate {
    func screenFrameDidChanged(toTime playedTime: Float, forTotalTime TotalTime: Float)
    func screenFrameDidFinishPlay(forTotalTime totalTime: Float)
    func screenFrameDidStartPlay()
    func screenFrameDidStartBuffer()
    func screenFrameDidEndBuffer()
    func screenFrameBufferTimeOut()
}

var timePeriodNotice: Any?


class VideoPlayerScreen: UIView, VLCMediaPlayerDelegate, VLCMediaDelegate, YTPlayerViewDelegate {
    var linkType: LinkType!
    var VLCplayer: VLCMediaPlayer!
    var ytPlayer: YTPlayerView!
    var avPlayer: AVPlayer!
    var avPlayerLayer: AVPlayerLayer!
    var markHasUpdated = false
    var bufferTime: TimeInterval = 0.0
    var firstLoading = false
    var isBuffering = false
    var delegate: VideoPlayerScreenDelegate?
    var playedTime: Float = 0.0
    var totalTime: Float = 0.0

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init?(for url: String, withFrame frame: CGRect) {
        self.init(frame: frame)
        // **** Set buffer time
        bufferTime = 30
        firstLoading = true
        // **** Judge link type
        var videoID: String! = ""
        if url.contains("youtube") || url.contains("youtu.be") {
            let regexPattern = "(?:(?:be|embed|v|\\?v=|v=|videos)|(?:[\\w+]+#\\w\\w(?:[\\w]+)?\\w))([\\w-_]+)"
            //"(?:youtube(?:-nocookie)?com/(?:[^/]+/.+/|(?:v|e(?:mbed)?)/|.*[?&]v=)|youtube/)([^\"&?/ ]{11})"
            let searchRange = NSRange(location: 0, length: url.count)
            let regex = try? NSRegularExpression(pattern: regexPattern, options: .caseInsensitive)
            let matches = regex!.matches(in: url , options: [], range: searchRange)
            let matchResult: NSTextCheckingResult = matches[0]
            let group1: NSRange = matchResult.range(at: 1)
            let urlNS: NSString = url as NSString
            videoID = urlNS.substring(with: group1)
        }

        if videoID != "" && videoID != "0" {
            linkType = LinkType.youtube
        } else {
            linkType = LinkType.directLink
        }
        if linkType == LinkType.directLink {
            
            var remoteURL = URL(string: url)
            // **** URL encode for m3u8 address
            if url.hasSuffix("m3u8") {
                var fileName = (url as NSString).lastPathComponent
                //fileName = fileName.urlencode()
                fileName = fileName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                let filePath = URL(fileURLWithPath: url).deletingLastPathComponent().absoluteString
                let fullPath = URL(fileURLWithPath: filePath).appendingPathComponent(fileName).absoluteString
                remoteURL = URL(string: fullPath)
            }
            var asset: AVAsset? = nil
            if let anURL = remoteURL {
                asset = AVAsset(url: anURL)
            }
            // **** If avPlayer is avaliable, use avPlayer
            if (asset?.isPlayable)! && !url.contains("rtmp://") {
                let playItem = AVPlayerItem(asset: asset!)
                avPlayer = AVPlayer(playerItem: playItem)
                avPlayerLayer = AVPlayerLayer(player: avPlayer)
                avPlayerLayer?.frame = bounds
                layer.addSublayer(avPlayerLayer!)
            } else {
                VLCplayer = VLCMediaPlayer()
                let media = VLCMedia(url: remoteURL)
                VLCplayer?.media = media
                VLCplayer?.media.delegate = self
                VLCplayer?.drawable = self
                VLCplayer?.delegate = self
            }
            //return self
            
        } else if linkType == LinkType.youtube {
            ytPlayer = YTPlayerView()
            let playVar = ["playsinline": 1, "autoplay": 0, "controls": 0, "rel": 0]
            ytPlayer.load(withVideoId: videoID, playerVars: playVar)
            ytPlayer.frame = bounds
            ytPlayer.delegate = self
            addSubview(ytPlayer)
            //return self
        }
        //return nil
    }
    
    func startPlay() {
        if VLCplayer != nil || avPlayer != nil {
            // **** Create timer for buffer
            if firstLoading {
                firstLoading = false
                isBuffering = true
                if #available(iOS 10.0, *) {
                    Timer.scheduledTimer(withTimeInterval: bufferTime, repeats: false, block: { timer in
                        timer.invalidate()
                        if self.isBuffering {
                            self.stopPlay()
                            self.delegate?.screenFrameBufferTimeOut()
                        }
                    })
                } else {
                    // Fallback on earlier versions
                }
                delegate?.screenFrameDidStartBuffer()
            }
        }
        if VLCplayer != nil {
            VLCplayer.play()
        } else if ytPlayer != nil {
            ytPlayer.playVideo()
        } else if avPlayer != nil {
            avPlayer.play()
            let second: CMTime = CMTimeMake(1, 30)
            weak var weakSelf = self
            
            timePeriodNotice = avPlayer.addPeriodicTimeObserver(forInterval: second, queue: DispatchQueue.main, using: { time in
                if (weakSelf != nil) {
                    let currentTime: Float = Float(CMTimeGetSeconds(CMTimeMake(self.avPlayer.currentTime().value, self.avPlayer.currentTime().timescale)))
                    let totalTime: Float = Float(CMTimeGetSeconds(CMTimeMake(self.avPlayer.currentItem!.duration.value, self.avPlayer.currentItem!.duration.timescale)))
                    weakSelf?.playedTime = currentTime
                    // **** Condition if player is still playing
                    if self.avPlayer.rate != 0 && self.avPlayer.error == nil {
                        weakSelf?.delegate?.screenFrameDidChanged(toTime: currentTime, forTotalTime: totalTime)
                    }
                    // **** Update mark info
                    if totalTime != 0.0 && !self.markHasUpdated {
                        self.markHasUpdated = true
                        weakSelf?.totalTime = totalTime
                        weakSelf?.delegate?.screenFrameDidStartPlay()
                        weakSelf?.delegate?.screenFrameDidEndBuffer()
                        self.isBuffering = false
                    }
                    
                }
            })
        }
    }
    
    func pausePlay() {
        if VLCplayer != nil {
            VLCplayer?.pause()
        } else if ytPlayer != nil {
            ytPlayer.pauseVideo()
        } else if avPlayer != nil {
            if timePeriodNotice != nil {
                avPlayer?.pause()
                avPlayer?.removeTimeObserver(timePeriodNotice!)
            }
        }
    }
    
    func stopPlay() {
        if VLCplayer != nil {
            VLCplayer?.stop()
            VLCplayer = nil
        } else if ytPlayer != nil {
            ytPlayer.stopVideo()
            ytPlayer.removeFromSuperview()
            ytPlayer = nil
        } else if avPlayer != nil {
            avPlayer?.pause()
            avPlayer?.removeTimeObserver(timePeriodNotice!)
            timePeriodNotice = nil
            avPlayer?.replaceCurrentItem(with: nil)
            avPlayer = nil
            avPlayerLayer.removeFromSuperlayer()
        }
    }
    
    func seek(toPosition position: Float) {
        if VLCplayer != nil {
            VLCplayer?.position = position
        } else if ytPlayer != nil {
            let videoLength:Float = Float(ytPlayer.duration())
            print(videoLength)
            let currentTime: Float = videoLength * position
            ytPlayer.seek(toSeconds: currentTime, allowSeekAhead: true)
        } else if avPlayer != nil {
            let seekedTime: CMTime = CMTimeMake(Int64(Float((avPlayer!.currentItem?.duration.value)!) * position), avPlayer!.currentItem!.duration.timescale)
            avPlayer?.seek(to: seekedTime)
        }
    }
    
    
    //pragma mark VLCMediaPayerDelegate
    func mediaPlayerTimeChanged(_ aNotification: Notification?) {
        if VLCplayer != nil {
            // **** Update control panel info
            self.playedTime = (Float(truncating: (VLCplayer?.media.length.value)!) + Float(truncating: (VLCplayer?.remainingTime.value)!)) / 1000
            let totalTime: Float = Float(truncating: VLCplayer!.media.length.value) / 1000
            delegate?.screenFrameDidChanged(toTime: playedTime, forTotalTime: totalTime)
            // **** Update mark info
            if totalTime != 0.0 && !markHasUpdated {
                self.totalTime = totalTime
                markHasUpdated = true
                delegate?.screenFrameDidStartPlay()
                delegate?.screenFrameDidEndBuffer()
                self.isBuffering = false
            }
        }
    }
    
    func mediaPlayerStateChanged(_ aNotification: Notification?) {
        if VLCplayer != nil {
            if VLCplayer?.state == .stopped {
                let totalTime: Float = Float(truncating: VLCplayer!.media.length.value) / 1000
                self.delegate?.screenFrameDidFinishPlay(forTotalTime: totalTime)
                self.VLCplayer?.position = 0
            }
        }
    }
    
    
    //pragma mark YTPlayerViewDelegate
    // **** YTPlayer autoplay
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        startPlay()
    }
    
    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float) {
        if ytPlayer != nil {
            playedTime = playTime
            let totalTime = Float(ytPlayer.duration())
            delegate?.screenFrameDidChanged(toTime: playedTime, forTotalTime: totalTime)
            if totalTime != 0 && !markHasUpdated {
                self.totalTime = totalTime
                markHasUpdated = true
                delegate?.screenFrameDidStartPlay()
            }
        }
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        if ytPlayer != nil {
            let state =  ytPlayer.playerState()
            if state == .ended {
                let totalTime = Float(self.ytPlayer.duration())
                delegate?.screenFrameDidFinishPlay(forTotalTime: totalTime)
            }
        }
    }
    
}




