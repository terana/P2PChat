//
// Created by terana on 10/05/2018.
// Copyright (c) 2018 Anastasia Terenteva. All rights reserved.
//

import UIKit

let kName = "Name"
let kMessages = "Messages"
let kMessage = "Message"
let kOnline = "Online"
let kUnread = "Unread"
let kDate = "Date"
let kSenders = "Senders"
let kUserID = "UserID"

class ChatListNetworkDataManager: CommunicatorDelegate, ChatListDataManager, ChatDataManageDelegate {
    var sendersDict = Dictionary<String, NSMutableDictionary>()
    var userName = "terana"
    weak var viewController: ChatListViewController!

    let communicator = MultipeerCommunicator()

    init() {
        communicator.delegate = self
    }

    var sendersArray: Array<NSDictionary> {
        return Array(sendersDict.values)
    }

    var offlineSenders: Array<NSDictionary> {
        return self.senders(online: false)
    }

    var onlineSenders: Array<NSDictionary> {
        return self.senders(online: true)
    }

    var hasOnlineSenders: Bool {
        return onlineSenders.count > 0
    }

    var hasOfflineSenders: Bool {
        return offlineSenders.count > 0
    }

    private func senders(online: Bool) -> Array<NSDictionary> {
        let result = self.sendersArray.flatMap({ (element) -> NSDictionary? in
            if let isOnline = element.object(forKey: kOnline) as? Bool {
                return isOnline == online ? element : nil
            }
            return nil
        })

        return result.sorted(by: { (element1, element2) -> Bool in
            if let date1 = element1.object(forKey: kDate) as? Date, let date2 = element2.object(forKey: kDate) as? Date {
                return date1.timeIntervalSince(date2) >= 0
            }
            return false
        })
    }

    func lastMessage(messages: Array<NSDictionary>) -> NSDictionary? {
        return messages.sorted(by: { (element1, element2) -> Bool in
            if let date1 = element1.object(forKey: kDate) as? Date, let date2 = element2.object(forKey: kDate) as? Date {
                return date2.timeIntervalSince(date1) >= 0
            }
            return false
        }).last
    }


    func messagesForIndexPath(indexPath: IndexPath) -> [NSDictionary] {
        let array = indexPath.section == 0 ? self.onlineSenders : self.offlineSenders
        let conversationDict = array[indexPath.row]
        let messages = conversationDict.object(forKey: kMessages) as? [NSDictionary] ?? []
        return messages
    }

    func nameForIndexPath(indexPath: IndexPath) -> String {
        let array = indexPath.section == 0 ? self.onlineSenders : self.offlineSenders
        let conversationDict = array[indexPath.row]
        return conversationDict.object(forKey: kName) as? String ?? ""
    }

    func userIDForIndexPath(indexPath: IndexPath) -> String {
        let array = indexPath.section == 0 ? self.onlineSenders : self.offlineSenders
        let conversationDict = array[indexPath.row]
        return conversationDict.object(forKey: kUserID) as? String ?? ""
    }

    func conversationCellViewModelForIndexPath(indexPath: IndexPath) -> ChatListCellViewModel {
        let array = indexPath.section == 0 ? self.onlineSenders : self.offlineSenders
        let conversationDict = array[indexPath.row]
        let conversationCellViewModel = ChatListCellViewModel()
        if let name = conversationDict.object(forKey: kName) as? String {
            conversationCellViewModel.name = name
        }
        if let online = conversationDict.object(forKey: kOnline) as? Bool {
            conversationCellViewModel.online = online
        }
        let messages = conversationDict.object(forKey: kMessages) as? [NSDictionary] ?? []
        let lastMessage = self.lastMessage(messages: messages) ?? NSDictionary()
        conversationCellViewModel.message = lastMessage.object(forKey: kMessage) as? String
        conversationCellViewModel.date = lastMessage.object(forKey: kDate) as? Date
        if let unread = lastMessage.object(forKey: kUnread) as? Bool {
            conversationCellViewModel.hasUnreadMessages = unread
        }
        return conversationCellViewModel
    }

    // MARK CommunicatorDelegate

    func failedToStartBrowsingForUsers(error: Error) {
        print("ChatListNetworkDataManager failedToStartBrowsingForUsers\n \(error)")
    }

    func failedToStartAdvertising(error: Error) {
        print("ChatListNetworkDataManager failedToStartAdvertising\n \(error)")
    }

    func didFoundUser(userID: String, userName: String?) {
        set(userID: userID, userName: userName, online: true)
    }

    func didLostUser(userID: String) {
        set(userID: userID, userName: nil, online: false)
    }

    private func set(userID: String, userName: String?, online: Bool) {
        guard let conversationDict = sendersDict[userID] else {
            let conversationDict: NSMutableDictionary = [
                kOnline: online,
                kUserID: userID,
                kUserName: userName ?? "NoName"
            ]
            sendersDict[userID] = conversationDict
            viewController.refresh()
            return
        }
        conversationDict[kOnline] = online
        if let userName = userName {
            conversationDict[kName] = userName
        }
        viewController.refresh()
    }

    func didReceiveMessage(text: String, fromUser: String, toUser: String) {
        let interlocutorID = fromUser == userName ? toUser : fromUser

        let message: NSDictionary = [
            kOutgoing: fromUser == userName,
            kUnread: true,
            kMessage: text,
            kDate: Date(timeIntervalSinceNow: TimeInterval(0))]
        guard let conversationDict = sendersDict[interlocutorID] else {
            sendersDict[interlocutorID] = [kMessages: [message], kUserID: interlocutorID]
            viewController.refresh()
            return
        }
        var messages = conversationDict.object(forKey: kMessages) as? [NSDictionary] ?? []
        messages.append(message)
        conversationDict[kMessages] = messages
        viewController.refresh()
    }

    //MARK ChatDataManageDelegate

    func send(message: NSDictionary, toUser receiverUserID: String) {
        guard let conversationDict = sendersDict[receiverUserID] else {
            sendersDict[receiverUserID] = [kMessages: [message], kUserID: receiverUserID]
            viewController.refresh()
            return
        }

        var messages = conversationDict.object(forKey: kMessages) as? [NSDictionary] ?? []
        messages.append(message)
        conversationDict[kMessage] = messages

        communicator.sendMessage(string: message.object(forKey: kMessage) as? String ?? "",
                to: receiverUserID, completionHandler: nil)
        viewController.refresh()
    }

}
