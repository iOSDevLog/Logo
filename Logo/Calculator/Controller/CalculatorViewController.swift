//
//  CalculatorViewController.swift
//  Logo
//
//  Created by developer on 8/20/19.
//  Copyright © 2019 iOSDevLog. All rights reserved.
//

import UIKit
import LogoCompiler

class CalculatorViewController: UITableViewController {
    var dataSource: [[String]]!
    let sections = ["Programm", "Calculating Programm"]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let str = dataSource[indexPath.section][indexPath.row]

        cell.textLabel?.text = str

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
}
