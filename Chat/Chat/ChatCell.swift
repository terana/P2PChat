//
//  ChatCell.swift
//  Chat
//
//  Created by terana on 01/05/2018.
//  Copyright © 2018 Anastasia Terenteva. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {

    func configureCell(withModel model: ChatCellViewModel) {
        self.textLabel?.textAlignment = model.outgoing ? .right : .left
        self.textLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel?.frame.size.width = 50
        self.textLabel?.text = model.message
        self.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.textLabel?.numberOfLines = 0
        self.textLabel?.adjustsFontSizeToFitWidth = true
    }
}
