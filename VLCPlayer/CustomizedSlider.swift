//
//  CustomizedSlider.swift
//  VLCTest
//
//  Created by rd on 2018/10/15.
//  Copyright © 2018年 rd. All rights reserved.
//

import UIKit

class CustomizedSlider: UISlider {
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var newBounds: CGRect = super.trackRect(forBounds: bounds)
        newBounds.size.height = 16
        return newBounds
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
