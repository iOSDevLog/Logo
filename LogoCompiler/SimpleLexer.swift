//
//  SimpleLexer.swift
//  LogoCompiler
//
//  Created by developer on 8/19/19.
//  Copyright © 2019 iOSDevLog. All rights reserved.
//

import Foundation

/**
 * 一个简单的手写的词法分析器。
 * 能够为后面的简单计算器、简单脚本语言产生Token。
 */
public class SimpleLexer {

    // MARK: - Property
    // 下面几个变量是在解析过程中用到的临时变量,如果要优化的话，可以塞到方法里隐藏起来
    // 临时保存token的文本
    private var tokenText: String? = nil
    // 保存解析出来的Token
    private var tokens: [Token]? = nil
    // 当前正在解析的Token
    private var token: SimpleToken? = nil

    // MARK: - Life Cycle
    public init() {
    }

    // MARK: - Character
    /// 是否是字母
    private func isAlpha(ch: Character) -> Bool {
        return ch.isLetter
    }

    /// 是否是数字
    private func isDigit(ch: Character) -> Bool {
        return ch.isNumber
    }

    /// 是否是空白字符
    private func isBlank(ch: Character) -> Bool {
        return String(ch) == " "
            || String(ch) == "\t"
            || String(ch) == "\n";

    }

    /**
     * 有限状态机进入初始状态。
     * 这个初始状态其实并不做停留，它马上进入其他状态。
     * 开始解析的时候，进入初始状态；某个Token解析完毕，也进入初始状态，在这里把Token记下来，然后建立一个新的Token。
     * @param ch
     * @return
     */
    private func initToken(ch: Character) -> DfaState {
        if (tokenText?.count ?? 0) > 0 {
            token?.text = tokenText
            tokens?.append(token!)

            tokenText = ""
            token = SimpleToken()
        }

        var newState = DfaState.Initial

        if ch.isLetter { // 第一个字符是字母
            if (String(ch) == "i") {
                newState = .Id_int1
            } else {
                newState = .Id // 进入Id状态
            }
            token?.type = .Identifier
            tokenText?.append(ch)
        } else if ch.isNumber { // 第一个字符是数字
            newState = .IntLiteral
            token?.type = .IntLiteral
            tokenText?.append(ch)
        } else {
            switch String(ch) {
            case ">":
                newState = .GT
                token?.type = .GT
                tokenText?.append(ch)
                break
            case "+":
                newState = .Plus
                token?.type = .Plus
                tokenText?.append(ch)
                break
            case "-":
                newState = .Minus
                token?.type = .Minus
                tokenText?.append(ch)
                break
            case "*":
                newState = .Star
                token?.type = .Star
                tokenText?.append(ch)
                break
            case "/":
                newState = .Slash
                token?.type = .Slash
                tokenText?.append(ch)
                break
            case ";":
                newState = .SemiColon
                token?.type = .SemiColon
                tokenText?.append(ch)
                break
            case "(":
                newState = .LeftParen
                token?.type = .LeftParen
                tokenText?.append(ch)
                break
            case ")":
                newState = .RightParen
                token?.type = .RightParen
                tokenText?.append(ch)
                break
            case "=":
                newState = .Assignment
                token?.type = .Assignment
                tokenText?.append(ch)
                break
            default:
                newState = .Initial; // skip all unknown patterns
                break
            }
        }

        return newState
    }

    /**
     * 解析字符串，形成Token。
     * 这是一个有限状态自动机，在不同的状态中迁移。
     * @param code
     * @return
     */
    public func tokenize(code: String) -> SimpleTokenReader {
        tokens = [Token]()
        guard code.count > 0 else {
            return SimpleTokenReader(tokens: tokens!)
        }
        tokenText = ""
        token = SimpleToken()

        var state = DfaState.Initial

        for ch in code {
            switch state {
            case .Initial:
                state = initToken(ch: ch) // 重新确定后续状态
            case .If:
                state = initToken(ch: ch); // 退出当前状态，并保存Token
                break
            case .Id_if1:
                state = initToken(ch: ch); // 退出当前状态，并保存Token
                break
            case .Id_if2:
                state = initToken(ch: ch); // 退出当前状态，并保存Token
                break
            case .Else:
                state = initToken(ch: ch); // 退出当前状态，并保存Token
                break
            case .Id_else1:
                state = initToken(ch: ch); // 退出当前状态，并保存Token
                break
            case .Id_else2:
                state = initToken(ch: ch); // 退出当前状态，并保存Token
                break
            case .Id_else3:
                state = initToken(ch: ch); // 退出当前状态，并保存Token
                break
            case .Id_else4:
                state = initToken(ch: ch); // 退出当前状态，并保存Token
                break
            case .Int:
                state = initToken(ch: ch); // 退出当前状态，并保存Token
                break
            case .Id_int1:
                if String(ch) == "n" {
                    state = .Id_int2
                    tokenText?.append(ch)
                } else if isDigit(ch: ch) || isAlpha(ch: ch) {
                    state = .Id // 切换回Id状态
                    tokenText?.append(ch)
                } else {
                    state = initToken(ch: ch)
                }
            case .Id_int2:
                if String(ch) == "t" {
                    state = .Id_int3
                    tokenText?.append(ch)
                } else if isDigit(ch: ch) || isAlpha(ch: ch) {
                    state = .Id // 切换回Id状态
                    tokenText?.append(ch)
                } else {
                    state = initToken(ch: ch)
                }
            case .Id_int3:
                if isBlank(ch: ch) {
                    token?.type = .Int
                    state = initToken(ch: ch)
                } else {
                    state = .Id
                    tokenText?.append(ch)
                }
            case .Id:
                if isAlpha(ch: ch) || isDigit(ch: ch) {
                    tokenText?.append(ch) // 保持标识符状态
                } else {
                    state = initToken(ch: ch) // 退出标识符状态，并保存 Token
                }
            case .GT:
                if String(ch) == "=" {
                    token?.type = .GE // 转换成 GE
                    state = .GE
                    tokenText?.append(ch)
                } else {
                    state = initToken(ch: ch) // 退出 GT 状态，并保存 Token
                }
            case .GE:
                state = initToken(ch: ch) // 退出 GE 状态，并保存 Token
                break
            case .Assignment:
                state = initToken(ch: ch) // 退出 Assignment 状态，并保存 Token
                break
            case .Plus:
                state = initToken(ch: ch) // 退出 Plus 状态，并保存 Token
                break
            case .Minus:
                state = initToken(ch: ch) // 退出 Minus 状态，并保存 Token
                break
            case .Star:
                state = initToken(ch: ch) // 退出 Star 状态，并保存 Token
                break
            case .Slash:
                state = initToken(ch: ch) // 退出 Slash 状态，并保存 Token
                break
            case .SemiColon:
                state = initToken(ch: ch) // 退出 SemiColon 状态，并保存 Token
                break
            case .LeftParen:
                break
            case .RightParen:
                state = initToken(ch: ch) // 退出当前状态，并保存Token
            case .IntLiteral:
                if isDigit(ch: ch) {
                    tokenText?.append(ch) // 继续保持在数字字面量状态
                } else {
                    state = initToken(ch: ch) // 退出当前状态，并保存Token
                }
            }
        }

        // 把最后一个token送进去
        if (tokenText?.count ?? 0) > 0 {
            _ = initToken(ch: code.last!);
        }

        return SimpleTokenReader(tokens: tokens!)
    }

    public static func dump(tokenReader: SimpleTokenReader) {
        print("text\ttype")
        var token: Token? = tokenReader.read()
        while let _token = token {
            print("\(String(describing: _token.getText()!))\t\t\(String(describing: _token.getType()!))")
            token = tokenReader.read()
        }
    }

    // MARK: Private enum
    /**
     * 有限状态机的各种状态。
     */
    private enum DfaState {
        case
        Initial,

        If, Id_if1, Id_if2, Else, Id_else1, Id_else2, Id_else3, Id_else4, Int, Id_int1, Id_int2, Id_int3, Id, GT, GE,

        Assignment,

        Plus, Minus, Star, Slash,

        SemiColon,
            LeftParen,
            RightParen,

        IntLiteral
    }

    // MARK: - private class
    /**
     * Token的一个简单实现。只有类型和文本值两个属性。
     */
    private class SimpleToken: Token {
        // Token类型
        var type: TokenType?

        // 文本值
        var text: String?

        func getType() -> TokenType? {
            return type
        }

        func getText() -> String? {
            return text
        }

    }

    /**
     * 一个简单的Token流。是把一个Token列表进行了封装。
     */
    public class SimpleTokenReader: TokenReader {
        var tokens = [Token]()
        var pos = 0

        public init(tokens: [Token]) {
            self.tokens = tokens
        }

        public func read() -> Token? {
            if pos < tokens.count {
                let token = tokens[pos]
                pos += 1
                return token
            }

            return nil
        }

        public func peek() -> Token? {
            if pos < tokens.count {
                return tokens[pos]
            }

            return nil
        }

        public func unread() {
            if pos > 0 {
                pos -= 1
            }
        }

        public func getPosition() -> Int {
            return pos
        }

        public func setPosition(position: Int) {
            if (position >= 0 && position < tokens.count) {
                pos = position
            }
        }
    }
}
