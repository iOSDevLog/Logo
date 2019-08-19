//
//  TokenType.swift
//  LogoCompiler
//
//  Created by developer on 8/19/19.
//  Copyright © 2019 iOSDevLog. All rights reserved.
//

import Foundation
/**
 * Token的类型
 */
public enum TokenType {
    case
    Plus, // +
    Minus, // -
    Star, // *
    Slash, // /

    GE, // >=
    GT, // >
    EQ, // ==
    LE, // <=
    LT, // <

    SemiColon, // ;
    LeftParen, // (
    RightParen, // )

    Assignment, // =

    If,
    Else,

    Int,

    Identifier, //标识符

    IntLiteral, //整型字面量
    StringLiteral //字符串字面量
}
