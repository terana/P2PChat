//
//  ChatCell.swift
//  Chat
//
//  Created by terana on 01/05/2018.
//  Copyright © 2018 Anastasia Terenteva. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {

    @IBOutlet weak var incomingMessageLabel: UILabel!
    @IBOutlet weak var outgoingMessageLabel: UILabel!
    
    func configureCell(withModel model: ChatCellViewModel) {
        let currentMessage = model.outgoing ? outgoingMessageLabel : incomingMessageLabel
        currentMessage?.isHidden = false
        currentMessage?.numberOfLines = 0
        currentMessage?.text = model.message
        let anotherMessage = !model.outgoing ? outgoingMessageLabel : incomingMessageLabel
        anotherMessage?.isHidden = true
    }
}
