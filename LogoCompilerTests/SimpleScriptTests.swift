//
//  SimpleScriptTests.swift
//  LogoCompilerTests
//
//  Created by developer on 8/23/19.
//  Copyright © 2019 iOSDevLog. All rights reserved.
//

import XCTest
@testable import LogoCompiler

class SimpleScriptTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testScript() {
        print("Simple script language!")

        SimpleScript.verbose = true
        let parser = SimpleParser()
        let script = SimpleScript()

        var scriptText = ""

        print("\n>")
        
        let lines = [
            "2+3;",
            "int age = 10;",
            "int b;",
            "b = 10*2;",
            "age = age + b;"
        ]

        for line in lines {
            do {
                scriptText += line + "\n"

                if line.hasSuffix(";") {
                    let tree = try parser.parse(code: scriptText)
                    
                    if let tree = tree {
                        if SimpleScript.verbose {
                            parser.dumpAST(node: tree, indent: "")
                        }
                        _ = try script.evaluate(node: tree, indent: "")
                    }
                     scriptText = ""
                }
            } catch LogoError.logo(let logoError) {
                print(logoError)
            } catch {
                print(error)
                print("\n>")
                scriptText = ""
            }
        }

    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
