//
//  TableViewController.swift
//  Chat
//
//  Created by Anastasia Terenteva on 3/15/18.
//  Copyright © 2018 Anastasia Terenteva. All rights reserved.
//

import UIKit

class ChatListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var dataManager = ChatListDataManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Chat"
        self.tableView.rowHeight = 70;
        tableView.delegate = self
        tableView.dataSource = self
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell", for: indexPath) as?
        ChatListCell else {
            fatalError("The dequeued cell is not an instance of ChatListTableViewCell.")
        }

        let model = dataManager.conversationCellViewModelForIndexPath(indexPath: indexPath)
        cell.configureCell(withModel: model)
        return cell
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let profileViewController = storyboard.instantiateInitialViewController() else {
            return
        }
        navigationController?.pushViewController(profileViewController, animated: true)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Online" : "Offline"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }


}
