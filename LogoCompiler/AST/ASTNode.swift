//
//  ASTNode.swift
//  LogoCompiler
//
//  Created by developer on 8/20/19.
//  Copyright © 2019 iOSDevLog. All rights reserved.
//

import Foundation

/**
 * AST的节点。
 * 属性包括AST的类型、文本值、下级子节点和父节点
 */
public protocol ASTNode {
    // 父节点
    func getParent() -> ASTNode?
    
    // 子节点
    func getChildren() -> [ASTNode]
    
    // AST类型
    func getType() -> ASTNodeType?
    
    // 文本值
    func getText() -> String?
}
