//
//  SimpleCalculator.swift
//  LogoCompiler
//
//  Created by developer on 8/20/19.
//  Copyright © 2019 iOSDevLog. All rights reserved.
//

import Foundation

/**
 * 实现一个计算器，但计算的结合性是有问题的。因为它使用了下面的语法规则：
 *
 * additive -> multiplicative | multiplicative + additive
 * multiplicative -> primary | primary + multiplicative
 *
 * 递归项在右边，会自然的对应右结合。我们真正需要的是左结合。
 */
public class SimpleCalculator {
    // MARK: - Property
    public var asts = [String]()
    public var evaluates = [String]()
    public var tree: ASTNode?
    
    // MARK: - Life Cycle
    public init() {
        
    }
    
    // MARK: - Helper
    /**
     * 执行脚本，并打印输出AST和求值过程。
     * @param script
     */
    public func evaluate(script: String) {
        self.asts.removeAll()
        self.evaluates.removeAll()
        
        do {
            if let tree = try parse(code: script) {
                self.tree = tree
                dumpAST(node: tree, indent: "")
                _ = evaluate(node: tree, indent: "")
            }
        } catch LogoError.logo(let logoError) {
            print(logoError)
        } catch {
            print(error)
        }
    }

    /**
     * 解析脚本，并返回根节点
     * @param code
     * @return
     * @throws Exception
     */
    func parse(code: String) throws -> ASTNode? {
        let lexer = SimpleLexer()
        let tokens = lexer.tokenize(code: code)

        let rootNode = try prog(tokens: tokens)

        return rootNode
    }

    /**
     * 对某个AST节点求值，并打印求值过程。
     * @param node
     * @param indent  打印输出时的缩进量，用tab控制
     * @return
     */
    func evaluate(node: ASTNode, indent: String) -> Int {
        var result = 0
        let str = "\(indent) Calculating: \(String(describing: node.getType()!))"
        print(str)
        evaluates.append(str)

        if let type = node.getType() {
            switch type {
            case .Programm:
                for child in node.getChildren() {
                    result = evaluate(node: child, indent: indent + "\t")
                }
                break
            case .Additive:
                let child1 = node.getChildren()[0]
                let value1 = evaluate(node: child1, indent: indent + "\t")
                let child2 = node.getChildren()[1]
                let value2 = evaluate(node: child2, indent: indent + "\t")

                if node.getText() == "+" {
                    result = value1 + value2
                } else {
                    result = value1 - value2
                }
                break
            case .Multiplicative:
                let child1 = node.getChildren()[0]
                let value1 = evaluate(node: child1, indent: indent + "\t")
                let child2 = node.getChildren()[1]
                let value2 = evaluate(node: child2, indent: indent + "\t")

                if node.getText() == "*" {
                    result = value1 * value2
                } else {
                    result = value1 / value2
                }
                break
            case .Primary:
                result = Int(node.getText()!)!
                break
            case .IntLiteral:
                result = Int(node.getText()!)!
                break
            default:
                break
            }
        }

        let resultStr = "\(indent) Result: \(result)"
        print(resultStr)
        evaluates.append(resultStr)

        return result;
    }
    /**
     * 语法解析：根节点
     * @return
     * @throws Exception
     */
    private func prog(tokens: TokenReader) throws -> SimpleASTNode? {
        let node = SimpleASTNode(nodeType: .Programm, text: "Calculator")
        let child = try additive(tokens: tokens)

        if let child = child {
            node.add(child: child)
        }

        return node
    }

    /**
     * 整型变量声明语句，如：
     * int a;
     * int b = 2*3;
     *
     * @return
     * @throws Exception
     */
    public func intDeclare(tokens: TokenReader) throws -> SimpleASTNode? {
        var node: SimpleASTNode? = nil
        var token = tokens.peek(); // 预读

        if token?.getType() == .Int {
            token = tokens.read() // 消耗掉int
            if tokens.peek()?.getType() == .Identifier { // 匹配标识符
                token = tokens.read() // 消耗掉标识符
                // 创建当前节点，并把变量名记到AST节点的文本值中，这里新建一个变量子节点也是可以的
                node = SimpleASTNode(nodeType: .IntDeclaration, text: token?.getText());
                token = tokens.peek(); //预读
                if token?.getType() == .Assignment {
                    _ = tokens.read(); // 消耗掉等号
                    let child = try additive(tokens: tokens) // 匹配一个表达式

                    if child == nil {
                        throw LogoError.logo(error: "invalide variable initialization, expecting an expression")
                    } else {
                        node?.add(child: child!)
                    }
                }
            } else {
                throw LogoError.logo(error: "variable name expected")
            }

            if node != nil {
                token = tokens.peek()
                if token?.getType() == .SemiColon {
                    _ = tokens.read()
                } else {
                    throw LogoError.logo(error: "invalid statement, expecting semicolon")
                }
            }
        }

        return node
    }

    /**
     * 语法解析：加法表达式
     * @return
     * @throws Exception
     */
    private func additive(tokens: TokenReader) throws -> SimpleASTNode? {
        let child1 = try multiplicative(tokens: tokens)
        var node = child1

        var token = tokens.peek()

        if let child1 = child1, let _ = token {
            if token?.getType() == .Plus || token?.getType() == .Minus {
                token = tokens.read()
                let child2 = try additive(tokens: tokens)

                if let child2 = child2 {
                    node = SimpleASTNode(nodeType: .Additive, text: token?.getText())
                    node?.add(child: child1)
                    node?.add(child: child2)
                } else {
                    throw LogoError.logo(error: "invalid additive expression, expecting the right part.")
                }
            }
        }

        return node
    }

    /**
     * 语法解析：乘法表达式
     * @return
     * @throws Exception
     */
    private func multiplicative(tokens: TokenReader) throws -> SimpleASTNode? {
        let child1: SimpleASTNode? = try primary(tokens: tokens)
        var node = child1
        var token = tokens.peek()

        if let child1 = child1, let _ = token {
            if token?.getType() == .Star || token?.getType() == .Slash {
                token = tokens.read()
                let child2 = try primary(tokens: tokens)

                if let child2 = child2 {
                    node = SimpleASTNode(nodeType: .Multiplicative, text: token?.getText())
                    node?.add(child: child1)
                    node?.add(child: child2)
                } else {
                    throw LogoError.logo(error: "invalid multiplicative expression, expecting the right part.")
                }
            }
        }

        return node
    }

    /**
     * 语法解析：基础表达式
     * @return
     * @throws Exception
     */
    private func primary(tokens: TokenReader) throws -> SimpleASTNode? {
        var node: SimpleASTNode? = nil
        var token = tokens.peek()

        if let _token = token {
            if _token.getType() == .IntLiteral {
                token = tokens.read()
                node = SimpleASTNode(nodeType: .IntLiteral, text: token?.getText())
            } else if token?.getType() == .Identifier {
                token = tokens.read()
                node = SimpleASTNode(nodeType: .Identifier, text: token?.getText())
            } else if token?.getType() == .LeftParen {
                let _ = tokens.read()
                node = try additive(tokens: tokens)

                if let _ = node {
                    if token?.getType() == .RightParen {
                        let _ = tokens.read()
                    } else {
                        throw LogoError.logo(error: "expecting right parenthesis")
                    }
                } else {
                    throw LogoError.logo(error: "expecting an additive expression inside parenthesis")
                }
            }
        }

        return node // 这个方法也做了 AST 的简化，就是不用构造一个 primary 节点，直接返回子节点。因为它只有一个子节点。
    }

    /**
     * 打印输出AST的树状结构
     * @param node
     * @param indent 缩进字符，由tab组成，每一级多一个tab
     */
    func dumpAST(node: ASTNode, indent: String) {
        let str = "\(indent)\(String(describing: node.getType()!)) \(String(describing: node.getText()!))"
        print(str)
        asts.append(str)
        for child in node.getChildren() {
            dumpAST(node: child, indent: indent + "\t");
        }
    }
}
