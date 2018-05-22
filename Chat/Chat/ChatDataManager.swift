import UIKit

let kOutgoing = "Outgoing"

class ChatDataManager {

    var sortedMessages: Array<NSDictionary>
    let name: String
    let userID: String
    weak var delegate: ChatDataManageDelegate!
    weak var chatViewController: ChatViewController!

    init(messagesArray: Array<NSDictionary>, name: String, userID: String,
         delegate: ChatDataManageDelegate) {
        self.sortedMessages = messagesArray.sorted(by: { (element1, element2) -> Bool in
            if let date1 = element1.object(forKey: kDate) as? Date, let date2 = element2.object(forKey: kDate) as? Date {
                return date2.timeIntervalSince(date1) >= 0
            }
            return false
        })
        self.name = name
        self.userID = userID
        self.delegate = delegate
    }


    func chatCellCellViewModelForIndexPath(indexPath: IndexPath) -> ChatCellViewModel {
        let messageCellViewModel = ChatCellViewModel()
        if (self.sortedMessages.count <= indexPath.row) {
            return messageCellViewModel
        }
        let message = self.sortedMessages[indexPath.row]
        if let outgoing = message.object(forKey: kOutgoing) as? Bool {
            messageCellViewModel.outgoing = outgoing
        }
        if let unread = message.object(forKey: kUnread) as? Bool {
            messageCellViewModel.unread = unread
        }
        messageCellViewModel.message = message.object(forKey: kMessage) as? String
        messageCellViewModel.date = message.object(forKey: kDate) as? Date
        return messageCellViewModel
    }

    func sendMessage(text: String) {
        let message: NSDictionary = [
            kOutgoing: true,
            kUnread: false,
            kMessage: text,
            kDate: Date(timeIntervalSinceNow: TimeInterval(0))]
        sortedMessages.append(message)
        chatViewController.refresh()

        delegate.send(message: message, toUser: userID)
    }

    func didReceive(message: NSDictionary) {
        sortedMessages.append(message)
        chatViewController.refresh()
    }
}
