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
    @IBOutlet weak var panelScrollView: UIScrollView!

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.lexer = SimpleLexer()
        self.calculator = SimpleCalculator()
        self.parser = SimpleParser()

        editorTextView.text = """
int a = 15;
int b = 19;
1+2-3+4*5-6;
int c = 1519;
int result = a+b*c;
"""
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tap))
        self.panelView.addGestureRecognizer(tap)
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
                            for layer in sublayers {
                                layer.removeFromSuperlayer()
                            }
                        }
                        self?.dumpAST(node: tree, position: CGPoint(x: self!.panelWidth / CGFloat(2), y: CGFloat(44)))
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

            if let asts = self?.parser.asts {
                dataSource.append(asts)
                DispatchQueue.main.async {
                    guard self != nil else {
                        return
                    }
                    self!.performSegue(withIdentifier: "calculatorSegue", sender: dataSource)
                    if let tree = self!.parser.tree {
                        if let sublayers = self?.panelView.layer.sublayers {
                            for layer in sublayers {
                                layer.removeFromSuperlayer()
                            }
                        }
                        self!.dumpAST(node: tree, position: CGPoint(x: self!.panelWidth / CGFloat(2), y: CGFloat(44)))

                        let rect = CGRect(x: (self!.panelWidth - self!.panelScrollView.bounds.width) / 2, y: 0, width: self!.panelScrollView.bounds.width, height: self!.panelScrollView.bounds.height)
                        self!.panelScrollView.scrollRectToVisible(rect, animated: true)
                    }
                }
            }
        }
    }

    @IBAction func clear(_ sender: UIBarButtonItem) {
        editorTextView.text = ""
    }

    // MARK: - Helper
    @objc func tap() {
        self.editorTextView.resignFirstResponder()
    }

    func dumpAST(node: ASTNode, position: CGPoint, level: Int = 1) {
        let childCount = node.getChildren().count
        let alpha: CGFloat = childCount > 0 ? 0.1 : 1
        let color: UIColor = node.getType()?.color.withAlphaComponent(alpha) ?? UIColor.magenta

        self.addNode(position, text: node.getText(), color: color)
        let newLevel = level + 1

        for index in 0..<childCount {
            let child = node.getChildren()[index]
            let maxWidth: CGFloat = CGFloat(512 * childCount) / CGFloat(pow(CGFloat(1.4), CGFloat(level)))
            let halfWidth: CGFloat = maxWidth / 2
            let offset: CGFloat = (maxWidth / CGFloat(childCount + 1)) * CGFloat(index + 1) - halfWidth
            let newPosition = CGPoint(x: position.x + offset, y: position.y + 50)
            self.addLine(position, endPosition: newPosition)
            dumpAST(node: child, position: newPosition, level: newLevel);
        }
    }

    // MARK: - Navigation
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

