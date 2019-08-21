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
    var calculator: SimpleCalculator!
    var parser: SimpleParser!

    // MARK: - Outlet
    @IBOutlet weak var editorTextView: UITextView!
    @IBOutlet weak var panelView: UIView!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.lexer = SimpleLexer()
        self.calculator = SimpleCalculator()
        self.parser = SimpleParser()

        editorTextView.text = """
1+2-3+4*5-6;

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

    @IBAction func calculator(_ sender: UIBarButtonItem) {
        let script = editorTextView.text!
        DispatchQueue.global().async { [weak self] in
            self?.calculator.evaluate(script: script)
            var dataSource = [[String]]()
            
            if let asts = self?.calculator.asts, let evaluates = self?.calculator.evaluates {
                dataSource.append(asts)
                dataSource.append(evaluates)
                DispatchQueue.main.async {
                    self?.performSegue(withIdentifier: "calculatorSegue", sender: dataSource)
                    if let tree = self?.calculator.tree {
                        if let sublayers = self?.panelView.layer.sublayers {
                            for layer in  sublayers {
                                layer.removeFromSuperlayer()
                            }
                        }
                        self?.dumpAST(node: tree, position: CGPoint(x: self!.panelWidth/CGFloat(2), y: CGFloat(44)))
                    }
                }
            }
        }
    }
    
    @IBAction func parse(_ sender: UIBarButtonItem) {
        let script = editorTextView.text!
        DispatchQueue.global().async { [weak self] in
            self?.parser.evaluate(code: script)
            var dataSource = [[String]]()
            
            if let asts = self?.parser.asts  {
                dataSource.append(asts)
                DispatchQueue.main.async {
                    self?.performSegue(withIdentifier: "calculatorSegue", sender: dataSource)
                    if let tree = self?.parser.tree {
                        if let sublayers = self?.panelView.layer.sublayers {
                            for layer in  sublayers {
                                layer.removeFromSuperlayer()
                            }
                        }
                        self?.dumpAST(node: tree, position: CGPoint(x: self!.panelWidth/CGFloat(2), y: CGFloat(44)))
                    }
                }
            }
        }
    }
    
    func dumpAST(node: ASTNode, position: CGPoint) {
        let childCount = node.getChildren().count
        let alpha: CGFloat = childCount > 0 ? 0.3 : 1
        self.addNode(position, text: node.getText(), alpha: alpha)
        
        for index in 0..<childCount {
            let child = node.getChildren()[index]
            let maxWidth: CGFloat = CGFloat(100 * childCount)
            let halfWidth: CGFloat = maxWidth / 2
            let offset: CGFloat = (maxWidth/CGFloat(childCount+1)) * CGFloat(index+1) - halfWidth
            let newPosition = CGPoint(x: position.x + offset, y: position.y + 50)
            self.addLine(position, endPosition: newPosition)
            dumpAST(node: child, position: newPosition);
        }
    }
    
    @IBAction func clear(_ sender: UIBarButtonItem) {
        editorTextView.text = ""
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "lexerSegue" {
            let lexerViewController = segue.destination as! LexerViewController
            lexerViewController.lexer = sender as? Lexer
        } else if segue.identifier == "calculatorSegue" {
            let calculatorViewController = segue.destination as! CalculatorViewController
            calculatorViewController.dataSource = sender as? [[String]]
        }
    }
}

