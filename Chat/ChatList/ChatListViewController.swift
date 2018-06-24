//
//  Created by Anastasia Terenteva on 3/15/18.
//  Copyright © 2018 Anastasia Terenteva. All rights reserved.
//

import UIKit

class ChatListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var dataManager = ChatListNetworkDataManager()

    @IBAction func onMyProfileButtonTap(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "ProfileViewController", bundle: nil)
        guard let profileViewController = storyboard.instantiateViewController(withIdentifier: "profileViewController")
                as? ProfileViewController else {
            fatalError("The view controller is not of type ProfileViewController.")
        }
        self.present(profileViewController, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Chat"
        self.tableView.rowHeight = 70;
        tableView.delegate = self
        tableView.dataSource = self
        self.dataManager.viewController = self
    }

    func refresh() {
        self.tableView.reloadData()
        self.tableView.setNeedsDisplay()
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
        let storyboard = UIStoryboard(name: "ChatViewController", bundle: nil)
        guard let chatViewController = storyboard.instantiateViewController(withIdentifier: "chatViewController") as? ChatViewController else {
            fatalError("The view controller is not of type ChatViewController.")
        }

        chatViewController.dataManager = ChatDataManager(
                messagesArray: dataManager.messagesForIndexPath(indexPath: indexPath),
                name: dataManager.nameForIndexPath(indexPath: indexPath),
                userID: dataManager.userIDForIndexPath(indexPath: indexPath),
                delegate: self.dataManager)

        navigationController?.pushViewController(chatViewController, animated: true)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Online" : "Offline"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? dataManager.onlineSenders.count : dataManager.offlineSenders.count
    }
}
