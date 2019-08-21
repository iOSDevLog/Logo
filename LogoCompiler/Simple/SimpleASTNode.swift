//
//  SimpleASTNode.swift
//  LogoCompiler
//
//  Created by developer on 8/21/19.
//  Copyright © 2019 iOSDevLog. All rights reserved.
//

import Foundation

/**
 * 一个简单的AST节点的实现。
 * 属性包括：类型、文本值、父节点、子节点。
 */
public class SimpleASTNode: ASTNode {
    var parent: SimpleASTNode? = nil
    var children = [ASTNode]()
    var nodeType: ASTNodeType? = nil
    var text: String? = nil
    
    public init(nodeType: ASTNodeType?, text: String?) {
        self.nodeType = nodeType
        self.text = text
    }
    
    public func getParent() -> ASTNode? {
        return parent
    }
    
    public func getChildren() -> [ASTNode] {
        let readonlyChildren = children
        return readonlyChildren
    }
    
    public func getType() -> ASTNodeType? {
        return nodeType
    }
    
    public func getText() -> String? {
        return text
    }
    
    func add(child: SimpleASTNode) {
        children.append(child)
        child.parent = self
    }
}
