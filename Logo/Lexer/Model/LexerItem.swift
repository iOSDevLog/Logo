//
//  LexerItem.swift
//  Logo
//
//  Created by developer on 8/19/19.
//  Copyright © 2019 iOSDevLog. All rights reserved.
//

import Foundation
import LogoCompiler

class LexerItem {
    public var title: String = ""
    public var tokens = [Token]()
    
    init(title: String, tokens: [Token]) {
        self.title = title
        self.tokens = tokens
    }
}
