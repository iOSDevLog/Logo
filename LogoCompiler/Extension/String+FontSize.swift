//
//  String+FontSize.swift
//  LogoCompiler
//
//  Created by developer on 8/21/19.
//  Copyright © 2019 iOSDevLog. All rights reserved.
//

import Foundation

public extension String {
    func size(ofFont font: UIFont) -> CGSize {
        return (self as NSString).size(withAttributes: [NSAttributedString.Key.font: font])
    }
}
