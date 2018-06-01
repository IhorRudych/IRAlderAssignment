//
//  CustomButton2.swift
//  IRAlderAssignment
//
//  Created by Ihor Rudych on 5/30/18.
//  Copyright © 2018 Ihor Rudych. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class CustomButton2:UIButton{
    
    @IBInspectable var borderWidth:CGFloat = 0{
        didSet{
            layer.borderWidth = borderWidth
    }
    }
    @IBInspectable var borderColor:UIColor = .black{
        didSet{
            layer.borderColor = borderColor.cgColor
        }
    }
    
    override func draw(_ rect: CGRect) {
        layer.cornerRadius = frame.height / 4
    }

}
