//
// Created by terana on 01/05/2018.
// Copyright (c) 2018 Anastasia Terenteva. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var dataManager: ChatDataManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = dataManager.name
        tableView.delegate = self
        tableView.dataSource = self
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as?
        ChatCell else {
            fatalError("The dequeued cell is not an instance of ChatListTableViewCell.")
        }

        let model = self.dataManager.chatCellCellViewModelForIndexPath(indexPath: indexPath)
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
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataManager.sortedMessages.count
    }
}

