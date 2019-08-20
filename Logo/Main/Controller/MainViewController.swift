//
//  MainViewController.swift
//  Logo
//
//  Created by developer on 8/19/19.
//  Copyright © 2019 iOSDevLog. All rights reserved.
//

import UIKit
import LogoCompiler

class MainViewController: UIViewController {
    var lexer: SimpleLexer!

    // MARK: - Outlet
    @IBOutlet weak var editorTextView: UITextView!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lexer = SimpleLexer()
        
        editorTextView.text = """
int a = 15;
int b = 19;
int c = 1519;
int result = a+b*c;
"""
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
    }

    // MARK: - Action
    @IBAction func lexer(_ sender: UIBarButtonItem) {
        let script = editorTextView.text!
        DispatchQueue.global().async { [weak self] in
            let tokenReader = self?.lexer.tokenize(code: script)
            let lexer = Lexer(title: "Lexer", lexerItems: [LexerItem]())
            var tokens = [Token]()
            var section = 0
            var token: Token? = tokenReader?.read()
            while let _token = token {
                tokens.append(_token)
                if _token.getType() == TokenType.SemiColon {
                    let item = LexerItem(title: "\(section)", tokens: tokens)
                    lexer.lexerItems.append(item)
                    tokens = [Token]()
                    section += 1
                }
                token = tokenReader?.read()
            }
            
            DispatchQueue.main.async {
                self?.performSegue(withIdentifier: "lexerSegue", sender: lexer)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "lexerSegue" {
            let lexerViewController = segue.destination as! LexerViewController
            lexerViewController.lexer = sender as? Lexer
        }
    }
}

