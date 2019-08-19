//
//  TokenReader.swift
//  LogoCompiler
//
//  Created by developer on 8/19/19.
//  Copyright © 2019 iOSDevLog. All rights reserved.
//

import Foundation
/**
 * 一个Token流。由Lexer生成。Parser可以从中获取Token。
 */
public protocol TokenReader {
    /**
     * 返回Token流中下一个Token，并从流中取出。 如果流已经为空，返回null;
     */
    func read() -> Token?
    /**
     * 返回Token流中下一个Token，但不从流中取出。 如果流已经为空，返回null;
     */
    func peek() -> Token?

    /**
     * Token流回退一步。恢复原来的Token。
     */
    func unread()

    /**
     * 获取Token流当前的读取位置。
     * @return
     */
    func getPosition() -> Int

    /**
     * 设置Token流当前的读取位置
     * @param position
     */
    func setPosition(position: Int)
}
