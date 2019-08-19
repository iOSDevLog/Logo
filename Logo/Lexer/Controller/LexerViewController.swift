//
//  LexerViewController.swift
//  Logo
//
//  Created by developer on 8/19/19.
//  Copyright © 2019 iOSDevLog. All rights reserved.
//

import UIKit
import LogoCompiler

class LexerViewController: UITableViewController {
    // MARK: - Property
    var lexer: Lexer!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = lexer.title
        self.tableView.tableFooterView = UIView()
    }
    
    // MARK: - TableViewDatasource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return lexer.lexerItems.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lexer.lexerItems[section].tokens.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let token = lexer.lexerItems[indexPath.section].tokens[indexPath.row]
        
        cell.textLabel?.text = "\(token.getType()!)"
        cell.detailTextLabel?.text = token.getText()
        
        return cell
    }
    
    // MARK: - TableViewDelegate
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return lexer.lexerItems[section].title
    }
}
