//
//  SimpleParserTests.swift
//  LogoCompilerTests
//
//  Created by developer on 8/21/19.
//  Copyright © 2019 iOSDevLog. All rights reserved.
//

import XCTest
@testable import LogoCompiler

class SimpleParserTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testParser() {
        let parser = SimpleParser()
        let script = "int age = 45+2; age= 20; age+10*2;"
        print("语法分析: \(script)")
        
        do {
            if let node = try parser.parse(code: script) {
                parser.dumpAST(node: node,indent: "")
            }
        } catch {
            print(error)
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
