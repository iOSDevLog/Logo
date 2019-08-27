//
//  REPLViewController+TableViewDelegate.swift
//  Logo
//
//  Created by developer on 8/27/19.
//  Copyright © 2019 iOSDevLog. All rights reserved.
//

import UIKit

extension REPLViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cmd = self.cmds[indexPath.row]

        if let tree = cmd.tree {
            plot(tree: tree)
        }
    }
}
