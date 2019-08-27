//
//  REPLViewController+TableViewDataSource.swift
//  Logo
//
//  Created by developer on 8/27/19.
//  Copyright © 2019 iOSDevLog. All rights reserved.
//

import UIKit

extension REPLViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cmds.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let cmd = cmds[indexPath.row]

        cell.textLabel?.text = cmd.input
        cell.detailTextLabel?.text = cmd.output

        return cell
    }
}
