//
//  SimpleParser.swift
//  LogoCompiler
//
//  Created by developer on 8/21/19.
//  Copyright © 2019 iOSDevLog. All rights reserved.
//

import Foundation

public class SimpleParser {
    // MARK: - Property
    public var asts = [String]()
    public var tree: ASTNode?

    // MARK: - Life Cycle
    public init() {

    }

    // MARK: - Helper
    public func evaluate(code: String) {
        do {
            if let tree = try self.parse(code: code) {
                self.tree = tree
                asts = [String]()
                self.dumpAST(node: tree, indent: "")
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
    public func parse(code: String) throws -> ASTNode? {
        let lexer = SimpleLexer()
        let tokens = lexer.tokenize(code: code)

        let rootNode = try prog(tokens: tokens)

        return rootNode
    }

    /**
     * 语法解析：根节点
     * @return
     * @throws Exception
     */
    private func prog(tokens: TokenReader) throws -> SimpleASTNode? {
        let node = SimpleASTNode(nodeType: .Programm, text: "AST")

        while tokens.peek() != nil {
            var child = try intDeclare(tokens: tokens)

            if child == nil {
                child = try expressionStatement(tokens: tokens)
            }

            if child == nil {
                child = try assignmentStatement(tokens: tokens)
            }

            if let _child = child {
                node.add(child: _child)
            } else {
                throw LogoError.logo(error: "unknown statement");
            }
        }

        return node
    }

    /**
     * 表达式语句，即表达式后面跟个分号。
     * @return
     * @throws Exception
     */
    public func expressionStatement(tokens: TokenReader) throws -> SimpleASTNode? {
        let pos = tokens.getPosition()
        var node = try additive(tokens: tokens)

        if let _ = node {
            let token = tokens.peek()
            if token?.getType() == .SemiColon {
                _ = tokens.read()
            } else {
                node = nil
                tokens.setPosition(position: pos)
            }
        }

        return node // 直接返回子节点，简化了AST。
    }

    /**
     * 赋值语句，如age = 10*2;
     * @return
     * @throws Exception
     */
    public func assignmentStatement(tokens: TokenReader) throws -> SimpleASTNode? {
        var node: SimpleASTNode? = nil
        var token = tokens.peek(); // 预读，看看下面是不是标识符

        if token?.getType() == .Identifier {
            token = tokens.read() // 读入标识符
            node = SimpleASTNode(nodeType: .AssignmentStmt, text: token?.getText())
            token = tokens.peek(); // 预读，看看下面是不是等号
            if token?.getType() == .Assignment {
                _ = tokens.read(); // 取出等号
                let child = try additive(tokens: tokens) // 匹配一个表达式
                if child == nil { // 出错，等号右面没有一个合法的表达式
                    throw LogoError.logo(error: "invalide assignment statement, expecting an expression")
                } else {
                    node?.add(child: child!) // 添加子节点
                    token = tokens.peek(); // 预读，看看后面是不是分号
                    if token?.getType() == .SemiColon {
                        _ = tokens.read() // 消耗掉这个分号
                    } else { // 报错，缺少分号
                        throw LogoError.logo(error: "invalid statement, expecting semicolon")
                    }
                }
            } else {
                tokens.unread() // 回溯，吐出之前消化掉的标识符
                node = nil
            }
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
                node = SimpleASTNode(nodeType: .IntDeclaration, text: token?.getText())
                token = tokens.peek(); // 预读
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
        var child1 = try multiplicative(tokens: tokens) // 应用add规则
        var node = child1

        if child1 != nil {
            while true { // 循环应用add'规则
                var token = tokens.peek()
                if token?.getType() == .Plus || token?.getType() == .Minus {
                    token = tokens.read() // 读出加号
                    let child2 = try multiplicative(tokens: tokens) // 计算下级节点
                    if child2 != nil {
                        node = SimpleASTNode(nodeType: .Additive, text: token?.getText())
                        node?.add(child: child1!) // 注意，新节点在顶层，保证正确的结合性
                        node?.add(child: child2!)
                        child1 = node
                    } else {
                        throw LogoError.logo(error: "invalid additive expression, expecting the right part.")
                    }
                } else {
                    break
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
        var child1: SimpleASTNode? = try primary(tokens: tokens)
        var node = child1

        if child1 != nil {
            while true {
                var token = tokens.peek()
                if token?.getType() == .Star || token?.getType() == .Slash {
                    token = tokens.read()
                    let child2 = try primary(tokens: tokens)

                    if child2 != nil {
                        node = SimpleASTNode(nodeType: .Multiplicative, text: token?.getText())
                        node?.add(child: child1!)
                        node?.add(child: child2!)
                        child1 = node
                    } else {
                        throw LogoError.logo(error: "invalid multiplicative expression, expecting the right part.")
                    }
                } else {
                    break
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

        if token != nil {
            if token!.getType() == .IntLiteral {
                token = tokens.read()
                node = SimpleASTNode(nodeType: .IntLiteral, text: token?.getText())
            } else if token!.getType() == .Identifier {
                token = tokens.read()
                node = SimpleASTNode(nodeType: .Identifier, text: token?.getText())
            } else if token!.getType() == .LeftParen {
                let _ = tokens.read()
                node = try additive(tokens: tokens)

                if node != nil {
                    token = tokens.peek()
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
    public func dumpAST(node: ASTNode, indent: String) {
        let str = "\(indent)\(String(describing: node.getType()!)) \(String(describing: node.getText()!))"
        print(str)
        asts.append(str)
        for child in node.getChildren() {
            dumpAST(node: child, indent: indent + "\t");
        }
    }
}
