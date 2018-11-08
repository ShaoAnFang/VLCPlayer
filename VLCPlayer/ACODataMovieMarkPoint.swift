//
//  ACODataMovieMarkPoint.swift
//  VLCTest
//
//  Created by rd on 2018/10/15.
//  Copyright © 2018年 rd. All rights reserved.
//

import UIKit

enum ACODataMovieMarkPointType : Int {
    case acoDataMovieMarkPointStar = 0
    case acoDataMovieMarkPointDifficult = 1
    case acoDataMovieMarkPointTemp = -1
}

class ACODataMovieMarkPoint: NSObject {
    var time: Float = 0.0
    var type: ACODataMovieMarkPointType!
    
    init(time: Float, with type: ACODataMovieMarkPointType) {
        super.init()
        self.time = time
        self.type = type
    }
}
