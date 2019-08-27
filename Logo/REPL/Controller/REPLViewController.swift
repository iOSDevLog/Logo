//
//  REPLViewController.swift
//  Logo
//
//  Created by developer on 8/27/19.
//  Copyright © 2019 iOSDevLog. All rights reserved.
//

import UIKit
import LogoCompiler

class REPLViewController: UIViewController {
    var cmds: [Cmd]!
    var parser: SimpleParser!
    var script: SimpleScript!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var panelScrollView: UIScrollView!
    @IBOutlet weak var panelView: UIView!
    @IBOutlet weak var cmdTextField: UITextField!
    @IBOutlet weak var execButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.parser = SimpleParser()
        self.script = SimpleScript()
        SimpleScript.verbose = true

        self.cmds = [Cmd]()

        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        self.execButton.addTarget(self, action: #selector(exec), for: .touchUpInside)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        fakeData()
    }

    func fakeData() {
        let lines = [
            "2+3;",
            "int age = 10;",
            "int tmp;",
            "tmp = 10*2;",
            "c",
            "age = age + tmp;",
            "int a = 15;",
            "int b = 19;",
            "1+2-3+4*5-6;",
            "int c = 1519;",
            "int result = a+b*c;",
        ]

        for line in lines {
            execCmd(code: line)
        }
    }

    @objc
    func keyboardWillShow(notification: NSNotification) {
        print("keyboardWillShow")
    }

    @objc
    func keyboardWillHide(notification: NSNotification) {
        print("keyboardWillHide")
    }

    @objc
    func keyboardWillChange(notification: NSNotification) {
        print("keyboardWillChange")
//        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
//        let curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        let curFrame = (notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let targetFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let deltaY = targetFrame.origin.y - curFrame.origin.y

        self.bottomConstraint.constant += deltaY
    }



    @objc func exec() {
        let code = self.cmdTextField.text

        defer {
            self.cmdTextField.text = ""
        }

        execCmd(code: code)
    }

    func execCmd(code: String?) {
        guard code != nil else {
            cmdTextField.becomeFirstResponder()
            return
        }

        do {
            let line = code!
            if line.hasSuffix(";") {
                let tree = try self.parser.parse(code: line)

                if let tree = tree {
                    if SimpleScript.verbose {
                        self.parser.dumpAST(node: tree, indent: "")
                    }
                    let result = try self.script.evaluate(node: tree, indent: "")
                    var output = "nil"
                    if let result = result {
                        output = String(describing: result)
                    }
                    let cmd = Cmd(input: line, output: output, tree: tree)
                    self.cmds.append(cmd)
                    self.tableView.reloadData()
                    let lastIndexPath = IndexPath(row: self.cmds.count - 1, section: 0)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                        self?.tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
                    }

                    plot(tree: tree)
                }
            } else {
                let cmd = Cmd(input: code!, output: "cmd should end with ‘;’", tree: nil)
                self.cmds.append(cmd)
                self.tableView.reloadData()
            }
        } catch LogoError.logo(let logoError) {
            print(logoError)
            let cmd = Cmd(input: code!, output: logoError, tree: nil)
            self.cmds.append(cmd)
            self.tableView.reloadData()
        } catch {
            print(error)
            print("\n>")
        }
    }

    func plot(tree: ASTNode) {
        if let sublayers = self.panelView.layer.sublayers {
            for layer in sublayers {
                layer.removeFromSuperlayer()
            }
        }
        self.dumpAST(node: tree, position: CGPoint(x: self.panelWidth / CGFloat(2), y: CGFloat(44)))
        let rect = CGRect(x: (self.panelWidth - self.panelScrollView.bounds.width) / 2, y: 0, width: self.panelScrollView.bounds.width, height: self.panelScrollView.bounds.height)
        self.panelScrollView.scrollRectToVisible(rect, animated: true)
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
}
