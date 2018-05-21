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

class ChatListNetworkDataManager: CommunicatorDelegate, ChatListDataManager {
    var sendersDict = Dictionary<String, NSDictionary>()
    var userName = "terana"

    lazy var sendersArray: Array<NSDictionary> = {
        return Array(sendersDict.values)
    }()

    lazy var offlineSenders: Array<NSDictionary> = {
        return self.senders(online: false)
    }()

    lazy var onlineSenders: Array<NSDictionary> = {
        return self.senders(online: true)
    }()

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


    // MARK ChatListDataManager
    func messagesForIndexPath(indexPath: IndexPath) -> [NSDictionary] {
        let array = indexPath.section == 0 ? self.onlineSenders : self.offlineSenders
        let conversationDict = array[indexPath.row]
        let messages = conversationDict.object(forKey: kMessages) as? [NSDictionary] ?? []
        return messages
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
    func didFoundUser(userID: String, userName: String?) {
        set(userID: userID, online: true)
    }

    func didLostUser(userID: String) {
        set(userID: userID, online: false)
    }

    private func set(userID: String, online: Bool) {
        guard let conversationDict = sendersDict[userID] as? NSMutableDictionary else {
            sendersDict[userID] = [kOnline: online]
            return
        }
        conversationDict[kOnline] = online
    }

    func didReceiveMessage(text: String, fromUser: String, toUser: String) {
        let interlocutorName = fromUser == userName ? toUser : fromUser

        let message: NSDictionary = [
            kOutgoing: fromUser == userName,
            kUnread: true,
            kMessage: text,
            kDate: Date(timeIntervalSinceNow: TimeInterval(0))]
        guard let conversationDict = sendersDict[interlocutorName] else {
            sendersDict[interlocutorName] = [kMessages: [message]]
            return
        }
        var messages = conversationDict.object(forKey: kMessages) as? [NSDictionary] ?? []
        messages.append(message)
    }

    func failedToStartBrowsingForUsers(error: Error) {
        print("ChatListNetworkDataManager failedToStartBrowsingForUsers\n \(error)")
    }

    func failedToStartAdvertising(error: Error) {
        print("ChatListNetworkDataManager failedToStartAdvertising\n \(error)")
    }

}
