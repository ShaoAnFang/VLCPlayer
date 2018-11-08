//
//  VideoPlayerControlPanel.swift
//  VLCTest
//
//  Created by rd on 2018/10/12.
//  Copyright © 2018年 rd. All rights reserved.
//

import UIKit

protocol ControlPanelDelegate {
    func controlPlay()
    func controlPause()
    func controlSeekVideo(atPosition percentage: Float)
}

class VideoPlayerControlPanel: UIView {
    var delegate: ControlPanelDelegate?
    var customButton1: UIButton!
    var customButton2: UIButton!
    var customButton3: UIButton!
    var customButton4: UIButton!
    var customButton5: UIButton!
    var customButtons: [UIButton] = []
    var markArea: UIView!
    
    var playButton: UIButton!
    var playedTimeLabel: UILabel!
    var totalTimeLabel: UILabel!
    var tracker: CustomizedSlider!
    var playing = false
    var tapGestOnTrack: UITapGestureRecognizer?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // **** autoplay, set playing default value
        playing = true

        // **** Set base panel view
        backgroundColor = UIColor.gray
        
        // **** Add slider for tracker bar
        // **** Create custom thumb image
        let pointerRect = CGRect(x: 0, y: 0, width: 5, height: 5)
        UIGraphicsBeginImageContextWithOptions(pointerRect.size, _: false, _: 0.0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.white.cgColor)
        context?.fillEllipse(in: pointerRect)
        let trackerThumb: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let trackerRect = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height * 0.5)
        tracker = CustomizedSlider(frame: trackerRect)
        tracker.backgroundColor = UIColor.clear
        tracker.minimumTrackTintColor = UIColor.yellow
        tracker.maximumTrackTintColor = UIColor.gray
        
        
        tracker.setThumbImage(UIImage(), for: .normal)
        tracker.addTarget(self, action: #selector(seekForVideo), for: .valueChanged)
        tapGestOnTrack = UITapGestureRecognizer(target: self, action: #selector(self.seekForVideoByTap(sender:)))
        tracker.addGestureRecognizer(tapGestOnTrack!)
        addSubview(tracker)
        
        // **** Add markarea
        markArea = UIView(frame: CGRect(x: 0, y: 0, width: tracker.frame.size.width, height: tracker.frame.size.height / 3))
        //        [self.markArea setBackgroundColor:[UIColor redColor]];
        tracker.addSubview(markArea)
        
        // **** Add basic button
        // **** Play button
        playButton = UIButton(type: .system)
        //        self.playButton.frame = CGRectMake(10, self.frame.size.height * 0.4, self.frame.size.height * 0.4, self.frame.size.height * 0.4);
        playButton.frame = CGRect(x: 10, y: frame.size.height * 0.6, width: frame.size.height * 0.3, height: frame.size.height * 0.3)
        
        playButton.setImage(UIImage(named: "ic_play_media"), for: .normal)
        addSubview(playButton)
        // **** Time label
        playedTimeLabel = UILabel()
        totalTimeLabel = UILabel()
        let font = UIFont(name: "Avenir-Medium", size: 16)
        playedTimeLabel.font = font
        totalTimeLabel.font = font
        playedTimeLabel.text = "00:00:00 /"
        totalTimeLabel.text = " 00:00:00"
        let playedTimeLabelSize: CGSize = playedTimeLabel.sizeThatFits(playedTimeLabel.frame.size)
        let totalTimeLabelSize: CGSize = totalTimeLabel.sizeThatFits(totalTimeLabel.frame.size)
        playedTimeLabel.frame = CGRect(x: playButton.frame.size.width + 15, y: playButton.frame.origin.y, width: playedTimeLabelSize.width, height: playedTimeLabelSize.height)
        totalTimeLabel.frame = CGRect(x: playedTimeLabel.frame.origin.x + playedTimeLabelSize.width, y: playedTimeLabel.frame.origin.y, width: totalTimeLabelSize.width, height: totalTimeLabelSize.height)
        addSubview(playedTimeLabel)
        addSubview(totalTimeLabel)
        
        // **** Add function
        playButton.addTarget(self, action: #selector(self.playButtonTapped), for: .touchUpInside)

    }
    
    convenience init(specialControlwithFrame frame: CGRect) {
        self.init(frame: frame)
        let customPanel = UIView(frame: CGRect(x: frame.size.width * 0.5, y: frame.size.height * 0.4, width: frame.size.width * 0.5, height: frame.size.height * 0.6))
        
        let btnMargin: CGFloat = 2
        let btnLength: CGFloat = customPanel.frame.size.height - (btnMargin * 2)
        let btnSize = CGSize(width: btnLength, height: btnLength)
        var originX: CGFloat = customPanel.frame.size.width - btnMargin - btnSize.width
        let originY: CGFloat = 0
        customButtons = [AnyHashable]() as! [UIButton]
        for _ in 0..<5 {
            let customButton = UIButton(type: .custom)
            customButton.frame = CGRect(x: originX, y: originY, width: btnSize.width, height: btnSize.height)
            customButton.imageView?.contentMode = .scaleAspectFit
            customPanel.addSubview(customButton)
            customButtons.append(customButton)
            originX -= btnSize.width + btnMargin * 3
        }
        self.addSubview(customPanel)

    }
    
    @objc func playButtonTapped() {
        if playing {
            playing = false
            playButton.setImage(UIImage(named: "ic_play_media"), for: .normal)
            delegate!.controlPause()
        } else {
            playing = true
            playButton.setImage(UIImage(named: "ic_stop_media"), for: .normal)
            delegate!.controlPlay()
        }
    }
    
    @objc func seekForVideo() {
        let position = tracker.value
        delegate?.controlSeekVideo(atPosition: position)
    }

    @objc func seekForVideoByTap(sender: UITapGestureRecognizer?) {
        let touched: CGPoint? = sender?.location(in: tracker)
        let position = Float((touched?.x ?? 0.0) / tracker.frame.size.width)
        print("touched:\(touched?.x ?? 0.0)")
        print("width:\(tracker.frame.size.width), height:\(tracker.frame.size.height)")
        tracker.setValue(position, animated: false)
        delegate?.controlSeekVideo(atPosition: position)
    }
    func parseTime(toString time: Float) -> String? {
        let hour = Int(time) / 3600
        let minute = (Int(time) % 3600) / 60
        let second = (Int(time) % 3600) % 60
        let hourString = (hour < 10) ? String(format: "0%i", hour) : String(format: "%i", hour)
        let minuteString = (minute < 10) ? String(format: "0%i", minute) : String(format: "%i", minute)
        let secondString = (second < 10) ? String(format: "0%i", second) : String(format: "%i", second)
        let timeString = "\(hourString):\(minuteString):\(secondString)"
        return timeString
    }

    func setInfoForPlayedTime(_ playedTime: Float, withTotoalTime totalTime: Float) {
        if playedTime == 0 {
            playButton.setImage(UIImage(named: "ic_play_media"), for: .normal)
        } else {
            playButton.setImage(UIImage(named: "ic_stop_media"), for: .normal)
        }
        tracker.setValue(playedTime / totalTime, animated: true)
        //playedTimeLabel.text = parseTime(toString: playedTime)
        //totalTimeLabel.text = parseTime(toString: totalTime)
    }
    
    func setInterfaceColor(_ color: UIColor?) {
        totalTimeLabel.textColor = color
        playedTimeLabel.textColor = color
        playButton.tintColor = color
    }

    
    
    
}
