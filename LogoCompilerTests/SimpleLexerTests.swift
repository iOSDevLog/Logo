//
//  SimpleLexerTests.swift
//  LogoCompilerTests
//
//  Created by developer on 8/19/19.
//  Copyright © 2019 iOSDevLog. All rights reserved.
//

import XCTest
@testable import LogoCompiler

class SimpleLexerTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSimpleLexerExample() {
        let lexer = SimpleLexer()

        // 测试 int 的解析
        var script = "int age = 45;"
        print("\nparse:\t\(script)")
        var tokenReader = lexer.tokenize(code: script)
        SimpleLexer.dump(tokenReader: tokenReader)

        // 测试 inta 的解析
        script = "inta age = 45;"
        print("\nparse:\t\(script)")
        tokenReader = lexer.tokenize(code: script)
        SimpleLexer.dump(tokenReader: tokenReader)

        // 测试 in 的解析
        script = "in age = 45;"
        print("\nparse:\t\(script)")
        tokenReader = lexer.tokenize(code: script)
        SimpleLexer.dump(tokenReader: tokenReader)

        // 测试 >= 的解析
        script = "age >= 45;"
        print("\nparse:\t\(script)")
        tokenReader = lexer.tokenize(code: script)
        SimpleLexer.dump(tokenReader: tokenReader)
        
        // 测试 > 的解析
        script = "age > 45;"
        print("\nparse:\t\(script)")
        tokenReader = lexer.tokenize(code: script)
        SimpleLexer.dump(tokenReader: tokenReader)
        
        // 测试 +-*/ 的解析
        script = "int a = 3; int b = 4; int c = 5; int x = a+b*c;"
        print("\nparse:\t\(script)")
        tokenReader = lexer.tokenize(code: script)
        SimpleLexer.dump(tokenReader: tokenReader)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
