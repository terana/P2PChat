//
// Created by terana on 10/05/2018.
// Copyright (c) 2018 Anastasia Terenteva. All rights reserved.
//

import UIKit

protocol CommunicatorDelegate: class {
    // discovering
    func didFoundUser(userID: String, userName: String?)
    func didLostUser(userID: String)

    // errors
    func failedToStartBrowsingForUsers(error: Error)
    func failedToStartAdvertising(error: Error)

    // messages
    func didReceiveMessage(text: String, fromUser: String, toUser: String)
}