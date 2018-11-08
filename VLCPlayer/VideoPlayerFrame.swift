//
//  VideoPlayerFrame.swift
//  VLCTest
//
//  Created by rd on 2018/10/12.
//  Copyright © 2018年 rd. All rights reserved.
//

import UIKit

//enum LinkType {
//    case Youtube
//    case DriectLink
//}


class VideoPlayerFrame: UIView, ControlPanelDelegate, VideoPlayerScreenDelegate {

    var screen: VideoPlayerScreen!
    var controlPanel: VideoPlayerControlPanel!
    var marks: [ACODataMovieMarkPoint]! = []
    var bufferCover: UIView!
    var customButtons: [UIButton] = []

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(for url: String?) {
        let orientationNumber = UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(orientationNumber, forKey: "orientation")
        //let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.height, height: UIScreen.main.bounds.size.width)
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        self.init(frame: frame)
        let screenRect = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        screen = VideoPlayerScreen(for: url!, withFrame: screenRect)
        screen.delegate = self
        //    CGRect panelRect = CGRectMake(0, frame.size.height - 120, frame.size.width, 120);
        let panelRect = CGRect(x: 0, y: frame.size.height * 0.75, width: frame.size.width, height: frame.size.height * 0.25)
        controlPanel = VideoPlayerControlPanel(specialControlwithFrame: panelRect)
        controlPanel.backgroundColor = UIColor(white: 0, alpha: 0.35)
        controlPanel.setInterfaceColor(UIColor.white)
        customButtons = controlPanel.customButtons
        controlPanel.delegate = self
        addSubview(screen)
        addSubview(controlPanel)
        startPlay()
    }
    
    convenience init(for url: String?, withMarkPoint markPoints: [ACODataMovieMarkPoint]?) {
        let orientationNumber = UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(orientationNumber, forKey: "orientation")
        //let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.height, height: UIScreen.main.bounds.size.width)
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        self.init(frame: frame)
        
        let screenRect = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        screen = VideoPlayerScreen(for: url!, withFrame: screenRect)
        screen.delegate = self
        
        let panelRect = CGRect(x: 0, y: frame.size.height * 0.75, width: frame.size.width, height: frame.size.height * 0.25)
        controlPanel = VideoPlayerControlPanel(specialControlwithFrame: panelRect)
        controlPanel.backgroundColor = UIColor(white: 0, alpha: 0.35)
        controlPanel.setInterfaceColor(UIColor.white)
        customButtons = controlPanel.customButtons
        controlPanel.delegate = self
        addSubview(screen)
        addSubview(controlPanel)
        if let markPointsArr = markPoints {
            marks = markPointsArr
        }
        startPlay()
    }
    
    func currentPlayedTime() -> Float {
        return screen.playedTime
    }
    
    func hideControlPanel() {
        controlPanel.alpha = 0
    }
    
    func showControlPanel() {
        controlPanel.alpha = 1
    }
    
    func updateMarkView(withMarkPoint markPoints: [ACODataMovieMarkPoint]) {
        if markPoints.count != 0 {
            for i in 0..<markPoints.count {
                
                let point: ACODataMovieMarkPoint! = markPoints[i]
                let pointImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: controlPanel.markArea.frame.size.height, height: controlPanel.markArea.frame.size.height))
                var iconImageName = ""
                switch point.type! {
                case .acoDataMovieMarkPointStar:
                    iconImageName = "video_starfull"
                case .acoDataMovieMarkPointDifficult:
                    iconImageName = "video_notification"
                default:
                    break
                }
                pointImageView.image = UIImage(named: iconImageName)
                pointImageView.contentMode = .scaleAspectFit
                let location = CGPoint(x: (CGFloat((point.time / screen.totalTime) * Float(controlPanel.markArea.frame.size.width))), y: controlPanel.markArea.frame.size.height / 2)
                pointImageView.center = location
                controlPanel.markArea.addSubview(pointImageView)
            }
        }
    }

    
    func addMarkPoint(atTime time: Float, with type: ACODataMovieMarkPointType) {
        let pointImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: controlPanel.markArea.frame.size.height, height: controlPanel.markArea.frame.size.height))
        var iconImageName = ""
        switch type {
        case .acoDataMovieMarkPointStar:
            iconImageName = "video_starfull"
        case .acoDataMovieMarkPointDifficult:
            iconImageName = "video_notification"
        case .acoDataMovieMarkPointTemp:
            iconImageName = "video_location"
        default:
            break
        }
        pointImageView.image = UIImage(named: iconImageName)
        pointImageView.contentMode = .scaleAspectFit
        
        let location = CGPoint(x: (CGFloat((time / screen.totalTime) * Float(controlPanel.markArea.frame.size.width))), y: controlPanel.markArea.frame.size.height / 2)
        pointImageView.center = location
        controlPanel.markArea.addSubview(pointImageView)
    }
    
    func startPlay() {
        screen.startPlay()
    }
    
    func stopPlay() {
        screen.stopPlay()
        //影片取消播放 將畫面轉回直向
        let orientationNumber = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(orientationNumber, forKey: "orientation")
    }
    
    //pragma mark ControlPanelDelegate
    func controlPlay() {
        self.screen.startPlay()
    }
    
    func controlPause() {
        self.screen.pausePlay()
    }
    
    func controlSeekVideo(atPosition percentage: Float) {
        self.screen.seek(toPosition: percentage)
    }
    
    
    //pragma mark VideoPlayerScreenDelegate
    func screenFrameDidChanged(toTime playedTime: Float, forTotalTime TotalTime: Float) {
        self.controlPanel.setInfoForPlayedTime(playedTime, withTotoalTime: TotalTime)
    }
    
    func screenFrameDidFinishPlay(forTotalTime totalTime: Float) {
        self.controlPanel.setInfoForPlayedTime(0, withTotoalTime: totalTime)
    }
    
    func screenFrameDidStartPlay() {
        self.updateMarkView(withMarkPoint: marks)
    }
    
    func screenFrameDidStartBuffer() {
        bufferCover = UIView(frame: bounds)
        bufferCover.backgroundColor = UIColor(white: 0.15, alpha: 0.9)
        let annotationLabel = UILabel()
        annotationLabel.text = NSLocalizedString("Movie_Buffering_Annotation", comment: "緩衝中、請稍待")
        annotationLabel.textColor = UIColor.white
        let labelSize = annotationLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        annotationLabel.frame = CGRect(x: 0, y: 0, width: labelSize.width, height: labelSize.height)
        annotationLabel.center = bufferCover.center
        bufferCover.addSubview(annotationLabel)
        let actIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        actIndicator.center = CGPoint(x: annotationLabel.center.x, y: annotationLabel.center.y - 30)
        bufferCover.addSubview(actIndicator)
        actIndicator.startAnimating()
        self.addSubview(bufferCover)
    }
    
    func screenFrameDidEndBuffer() {
        bufferCover.removeFromSuperview()
    }
    
    func screenFrameBufferTimeOut() {
        for subView: UIView? in bufferCover.subviews {
            subView?.removeFromSuperview()
        }
        let annotationLabel = UILabel()
        annotationLabel.text = NSLocalizedString("Movie_Buffer_Timeout_Annotation", comment: "影片載入逾時、請檢查網路狀態或稍候再試")
        annotationLabel.textColor = UIColor.white
        let labelSize = annotationLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        annotationLabel.frame = CGRect(x: 0, y: 0, width: labelSize.width, height: labelSize.height)
        annotationLabel.center = bufferCover.center
        bufferCover.addSubview(annotationLabel)
        controlPanel.isUserInteractionEnabled = false
    }
    
    
    
}
