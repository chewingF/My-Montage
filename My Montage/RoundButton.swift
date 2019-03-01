//
//  RoundButton.swift
//  My Montage
//
//  Created by 陈念 on 17/5/31.
//  Copyright © 2017年 nche75. All rights reserved.
//

import Foundation
import UIKit
@IBDesignable

class RoundButton : UIButton{
    //this is defined to make buttons have more features can be set from storyboard directly.
    
    //to make corners round
    @IBInspectable var cornerRadius : CGFloat = 0 {
        didSet{
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    //to set the the width of board
    @IBInspectable var borderWidth : CGFloat = 0 {
        didSet{
            self.layer.borderWidth = borderWidth
        }
    }
    
    //and the color of board
    @IBInspectable var borderColor : UIColor = UIColor.clear {
        didSet{
            self.layer.borderColor = borderColor.cgColor
        }
    }
}
