//
//  ASTNodeType.swift
//  LogoCompiler
//
//  Created by developer on 8/20/19.
//  Copyright © 2019 iOSDevLog. All rights reserved.
//

import Foundation

/**
 * AST节点的类型。
 */
public enum ASTNodeType {
    case
    Programm, // 程序入口，根节点

    IntDeclaration, // 整型变量声明
    ExpressionStmt, // 表达式语句，即表达式后面跟个分号
    AssignmentStmt, // 赋值语句

    Primary, // 基础表达式
    Multiplicative, // 乘法表达式
    Additive, // 加法表达式

    Identifier, // 标识符
    IntLiteral // 整型字面量

    public var color: UIColor {
        switch self {
        case .Programm:
            return UIColor.black
        case .IntDeclaration:
            return UIColor.blue
        case .ExpressionStmt:
            return UIColor.green
        case .AssignmentStmt:
            return UIColor.gray
        case .Primary:
            return UIColor.red
        case .Multiplicative:
            return UIColor.purple
        case .Additive:
            return UIColor.brown
        case .Identifier:
            return UIColor.yellow
        case .IntLiteral:
            return UIColor.cyan
        }
    }
}
