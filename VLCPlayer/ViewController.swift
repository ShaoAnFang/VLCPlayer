//
//  ViewController.swift
//  VLCTest
//
//  Created by rd on 2018/10/12.
//  Copyright © 2018年 rd. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var player: VideoPlayerFrame!
    var videoTransparentCover: UIView!
    var tapGesture: UITapGestureRecognizer!
    var VLCplayer: VLCMediaPlayer!
    
    var v: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        VLCplayer = VLCMediaPlayer()
//        let remoteURL = URL(string: "rtmp://192.168.0.182/live/Clark")
//        let media = VLCMedia(url: remoteURL)
//        VLCplayer?.media = media
//        VLCplayer?.drawable = v
//        VLCplayer.play()
//        view.addSubview(v)
        
        let url = "http://203.74.121.43/api/HLS/VklOREVYXzAwMDAyNjgwLkNIMS5RMA==<webapi>1113.m3u8"
        //let url = "https://www.youtube.com/watch?v=gR7ko81rA-8"
        //let url = "https://firebasestorage.googleapis.com/v0/b/python-f5763.appspot.com/o/Eason%20%E9%99%B3%E5%A5%95%E8%BF%85%20%E3%80%90%E5%BF%83%E7%9A%84%E8%B7%9D%E9%9B%A2%E3%80%91MV.mp4?alt=media&token=44260fd0-bf26-4d27-8506-9561d8c87246"
        
        //let url = "http://203.74.121.43/api/HLS/VklOREVYXzAwMDAxNzY1LkNIMS5RMA==<webapi>3305.m3u8"
       
//            marker = (
//        {
//            time = 6;
//            type = 0;
//        },
//        {
//            time = 8;
//            type = 1;
//        },pa
//        {
//            time = 11;
//            type = 1;
//        }
//        );
        
          player = VideoPlayerFrame(for: url)
        
//        var points: [ACODataMovieMarkPoint] = []
//        let ps = [["time": 6, "type": 0], ["time": 8, "type": 1], ["time": 11, "type": 1]] as Array
//        for p in ps {
//            let time: Float = Float(p["time"]!)
//            let type = p["type"]
//            let point = ACODataMovieMarkPoint(time: time, with: ACODataMovieMarkPointType(rawValue: type!)!)
//            points.append(point)
//        }
//
//        print(points)
//        player = VideoPlayerFrame(for: url, withMarkPoint: points )
//
//        videoTransparentCover = UIView(frame: CGRect(x: player.frame.origin.x, y: player.frame.origin.y, width: player.frame.size.width, height: player.frame.size.height - player.controlPanel.frame.size.height))
//
//        player.customButtons[0].setImage(UIImage(named: "video_location"), for: .normal)
//        player.customButtons[0].addTarget(self, action: #selector(self.addTempMarkerForVideo), for: .touchUpInside)
//        player.customButtons[1].setImage(UIImage(named: "video_notification"), for: .normal)
//        player.customButtons[1].addTarget(self, action: #selector(self.addDifficultMarkerForVideo), for: .touchUpInside)
//        player.customButtons[2].setImage(UIImage(named: "video_starfull"), for: .normal)
//        player.customButtons[2].addTarget(self, action: #selector(self.addStarMarkerForVideo), for: .touchUpInside)


        //videoTransparentCover = UIView(frame: CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.size.width, height: view.frame.size.height))
        //videoTransparentCover.addGestureRecognizer(tapGesture)
        player.addSubview(videoTransparentCover)
        view.addSubview(player)
        

    }
    
    @objc func addStarMarkerForVideo() {
        print("addStarMarkerForVideo")
        //if player == nil || movieObj == nil {
        //    return
        //}
        let playerForBlock: VideoPlayerFrame? = player
        //movieObj.setMovieMarkerAtTime(player.currentPlayedTime, forType: ACODataMovieMarkPointStar, withHandler: {
        //    playerForBlock?.addMarkPoint(atTime: playerForBlock?.currentPlayedTime, withType: ACODataMovieMarkPointStar)
        //})
    }
    
    @objc func addDifficultMarkerForVideo() {
        print("addDifficultMarkerForVideo")
        //if player == nil || movieObj == nil {
        //    return
        //}
        let playerForBlock: VideoPlayerFrame? = player
        //movieObj.setMovieMarkerAtTime(player.currentPlayedTime, forType: ACODataMovieMarkPointDifficult, withHandler: {
        //    playerForBlock?.addMarkPoint(atTime: playerForBlock?.currentPlayedTime, withType: ACODataMovieMarkPointDifficult)
        //})
    }

    @objc func addTempMarkerForVideo() {
        print("addTempMarkerForVideo")
        //if player == nil || movieObj == nil {
        //    return
        //}
        //player.addMarkPoint(atTime: player.currentPlayedTime, withType: ACODataMovieMarkPointTemp)
    }
    
    
    
    
}
