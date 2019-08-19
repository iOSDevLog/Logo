//
//  Lexer.swift
//  Logo
//
//  Created by developer on 8/19/19.
//  Copyright © 2019 iOSDevLog. All rights reserved.
//

import Foundation
import LogoCompiler

class Lexer {
    var title: String
    var lexerItems = [LexerItem]()
    
    init(title: String, lexerItems: [LexerItem]) {
        self.title = title
        self.lexerItems = lexerItems
    }
    
    init() {
        self.title = ""
        self.lexerItems = [LexerItem]()
    }
}
