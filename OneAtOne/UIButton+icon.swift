//
//  UIButton+icon.swift
//  OneAtOne
//
//  Created by Finlay, Kate on 1/4/17.
//  Copyright © 2017 1@1. All rights reserved.
//

import Foundation
import UIKit

internal extension UIButton {
    
    func leadTitle(withFontAwesomeIconNamed name: String) {
        if let titleText = self.titleLabel?.text {
            let buttonString = String.fontAwesomeString(name: name) + " " + titleText
            let buttonStringAttributed = NSMutableAttributedString(string: buttonString, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 13.0)])
            buttonStringAttributed.addAttribute(NSFontAttributeName, value: UIFont.iconFontOfSize(font: "FontAwesome", fontSize: 14), range: NSRange(location: 0,length: 1))
            
            self.setAttributedTitle(buttonStringAttributed, for: .normal)
        }

    }

}
