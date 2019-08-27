//
//  SimpleScript.swift
//  LogoCompiler
//
//  Created by developer on 8/23/19.
//  Copyright © 2019 iOSDevLog. All rights reserved.
//

import Foundation

/**
 * 一个简单的脚本解释器。
 * 所支持的语法，请参见SimpleParser.java
 *
 * 运行脚本：
 * 在命令行下，键入：java SimpleScript
 * 则进入一个REPL界面。你可以依次敲入命令。比如：
 * > 2+3;
 * > int age = 10;
 * > int b;
 * > b = 10*2;
 * > age = age + b;
 * > exit();  //退出REPL界面。
 *
 * 你还可以使用一个参数 -v，让每次执行脚本的时候，都输出AST和整个计算过程。
 *
 */
public class SimpleScript {
    // MARK: - Property
    var variables = [String: Int?]()
    public static var verbose = false

    public init() {

    }

    // MARK: - Helper
    public func evaluate(node: ASTNode, indent: String) throws -> Int? {
        var result: Int? = nil

        if SimpleScript.verbose {
            print("\(indent)Calculating: \(String(describing: node.getType()!))")
        }

        if let type = node.getType() {
            switch type {
            case .Programm:
                for child in node.getChildren() {
                    result = try evaluate(node: child, indent: indent)
                }
                break
            case .ExpressionStmt:
                break
            case .AssignmentStmt:
                let varName = node.getText()!
                if !variables.keys.contains(varName) {
                    throw LogoError.logo(error: "unknown variable: \(varName)")
                } //接着执行下面的代码
                fallthrough
            case .IntDeclaration:
                let varName = node.getText()!
                var varValue: Int? = nil

                if node.getChildren().count > 0 {
                    let child = node.getChildren()[0]
                    result = try evaluate(node: child, indent: "\t")
                    varValue = Int(result!)
                }
                variables[varName] = varValue
                break
            case .Primary:
                break
            case .Multiplicative:
                let child1 = node.getChildren()[0]
                let value1 = try evaluate(node: child1, indent: "\t")
                let child2 = node.getChildren()[1]
                let value2 = try evaluate(node: child2, indent: "\t")

                if node.getText()! == "*" {
                    result = value1! * value2!
                } else {
                    result = value1! / value2!
                }
                break
            case .Additive:
                let child1 = node.getChildren()[0]
                let value1 = try evaluate(node: child1, indent: "\t")
                let child2 = node.getChildren()[1]
                let value2 = try evaluate(node: child2, indent: "\t")

                if node.getText()! == "+" {
                    result = value1! + value2!
                } else {
                    result = value1! - value2!
                }
                break
            case .Identifier:
                let varName = node.getText()!
                if variables.keys.contains(varName) {
                    let value = variables[varName]

                    if value != nil {
                        result = value!
                    } else {
                        throw LogoError.logo(error: "variable \(varName) has not been set any value")
                    }
                } else {
                    throw LogoError.logo(error: "unknown variable: \(varName)")
                }
                break
            case .IntLiteral:
                result = Int(node.getText()!)
                break
            }

            if SimpleScript.verbose {
                print("\(indent)Result: \(String(describing: result))")
            } else if indent == "" { // 顶层的语句
                if node.getType() == .IntDeclaration || node.getType() == .AssignmentStmt {
                    print("\(String(describing: node.getText())):  \(String(describing: result))")
                } else {
                    print(String(describing: result))
                }
            }
        }

        return result
    }
}
