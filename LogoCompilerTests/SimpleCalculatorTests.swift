//
//  SimpleCalculatorTests.swift
//  SimpleCalculatorTests
//
//  Created by developer on 8/19/19.
//  Copyright © 2019 iOSDevLog. All rights reserved.
//

import XCTest
@testable import LogoCompiler

class SimpleCalculatorTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCalculator() {
        let calculator = SimpleCalculator()
        var script = "int a = b+3;"
        print("解析变量声明语句: \(script)")
        let lexer = SimpleLexer()
        let tokens = lexer.tokenize(code: script)
        
        do {
            if let node = try calculator.intDeclare(tokens: tokens) {
                calculator.dumpAST(node: node,indent: "")
            }
        } catch {
            print(error)
        }
        
        // 测试表达式
        script = "2+3*5"
        print("\n计算: \(script)，看上去一切正常。")
        calculator.evaluate(script: script)
        
        script = "2+3+4"
        print("\n计算: \(script)，结合性出现错误。")
        calculator.evaluate(script: script)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
