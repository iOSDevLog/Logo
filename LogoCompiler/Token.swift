//
//  Token.swift
//  LogoCompiler
//
//  Created by developer on 8/19/19.
//  Copyright © 2019 iOSDevLog. All rights reserved.
//

import Foundation
/**
 * 一个简单的Token。
 * 只有类型和文本值两个属性。
 */
public protocol Token {

    /**
     * Token的类型
     * @return
     */
    func getType() -> TokenType?

    /**
     * Token的文本值
     * @return
     */
    func getText() -> String?

}
