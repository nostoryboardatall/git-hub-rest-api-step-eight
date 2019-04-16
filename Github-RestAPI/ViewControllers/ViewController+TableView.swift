//
//  ViewController+TableView.swift
//
//  Created by Home on 2019.
//  Copyright 2017-2018 NoStoryboardsAtAll Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
//  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // if total count < items.count => return items.count + 1 (for append)
        guard let items = fetchedRepositories?.items, let total = fetchedRepositories?.total else { return 0 }
        return ( items.count < total ) ? items.count + 1 : items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // if we are going to show appending cell?
        let cellID = ( indexPath.row < fetchedRepositories?.items?.count ?? -1 ) ? repositoryCellID : appendCellID
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        if let cell = cell as? RepositoryCell {
            if let repository = fetchedRepositories?.items?[indexPath.row] {
                cell.repository = repository
            }
        } else if let cell = cell as? AppendCell {
            appendingView = cell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? AppendCell {
            // start appending
            cell.startAppending()
            append()
        }
    }
    
    // Special trick for tableView do not show table rows more than it has
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRect.zero)
    }
    
    @objc func refreshTableView() {
        // will execute search only if keyword is not empty
        if ( !(keyword?.isEmpty ?? true) ) {
            fetch()
        } else {
            tableView.refreshControl?.endRefreshing()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let repository = fetchedRepositories?.items?[indexPath.row] else { return }
        
        let detailViewController = DetailController()
        detailViewController.repository = repository
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}
