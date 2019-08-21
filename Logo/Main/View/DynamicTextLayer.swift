//
//  DynamicTextLayer.swift
//  Logo
//
//  Created by developer on 8/21/19.
//  Copyright © 2019 iOSDevLog. All rights reserved.
//

import UIKit

class DynamicTextLayer : CATextLayer {
    var adjustsFontSizeToFitWidth = false
    
    override func layoutSublayers() {
        super.layoutSublayers()
        if adjustsFontSizeToFitWidth {
            fitToFrame()
        }
    }
    
    func fitToFrame(){
        // Calculates the string size.
        var stringSize: CGSize  {
            get { return (string as? String)!.size(ofFont: UIFont(name: (font as! UIFont).fontName, size: fontSize)!) }
        }
        // Adds inset from the borders. Optional
        let inset: CGFloat = 2
        // Decreases the font size until criteria met
        while frame.width < stringSize.width + inset {
            fontSize -= 1
        }
    }
}
