//
//  ChatListCell.swift
//  Chat
//
//  Created by terana on 30/04/2018.
//  Copyright © 2018 Anastasia Terenteva. All rights reserved.
//

import UIKit

class ChatListCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!

    func configureCell(withModel model: ChatListCellViewModel) {
        nameLabel.text = model.name
        timeLabel.text = formatDate(date: model.date)
        messageLabel.text = model.message
        if (model.online) {
            self.backgroundColor = UIColor(red: 1.00, green: 239 / 255, blue: 150 / 255, alpha: 1.00)
        }
        if (model.hasUnreadMessages) {
            messageLabel.font = UIFont.boldSystemFont(ofSize: messageLabel.font.pointSize)
        }
    }

    func formatDate(date: Date?) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        guard let strong_date = date else {
            return "NoDate"
        }
        return formatter.string(from: strong_date)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = ""
        timeLabel.text = ""
        messageLabel.text = ""
        self.backgroundColor = UIColor.white
        messageLabel.font = UIFont.systemFont(ofSize: messageLabel.font.pointSize)
    }
}
