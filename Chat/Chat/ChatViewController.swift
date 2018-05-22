//
// Created by terana on 01/05/2018.
// Copyright (c) 2018 Anastasia Terenteva. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newMessageInputField: UITextField!

    @IBAction func onSendButtonPressed(_ sender: UIButton) {
        let text = newMessageInputField.text!
        dataManager.sendMessage(text: text)
        newMessageInputField.text = ""
    }

    var dataManager: ChatDataManager!


    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = dataManager.name
        tableView.delegate = self
        tableView.dataSource = self
        self.dataManager.chatViewController = self
    }

    func refresh() {
        self.tableView.reloadData()
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dataManager.chatCellCellViewModelForIndexPath(indexPath: indexPath)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: model.outgoing ?
                "OutgoingMessageCell" : "IncomingMessageCell", for: indexPath) as? ChatCell else {
            fatalError("Dequeud cell is not ChatCell.")
        }
        cell.configureCell(withModel: model)

        return cell
    }

    // MARK: UITableViewDelegate

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataManager.sortedMessages.count
    }

}

