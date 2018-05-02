
import UIKit

let kOutgoing = "Outgoing"

class ChatDataManager {

	var sortedMessages: Array<NSDictionary>
	let name: String?

	init(messagesArray: Array<NSDictionary>, name: String?) {
		self.sortedMessages = messagesArray.sorted(by: { (element1, element2) -> Bool in
			if let date1 = element1.object(forKey: kDate) as? Date, let date2 = element2.object(forKey: kDate) as? Date {
				return date2.timeIntervalSince(date1) >= 0
			}
			return false
		})
		self.name = name
	}

	func chatCellCellViewModelForIndexPath(indexPath: IndexPath) -> ChatCellViewModel {
		let messageCellViewModel = ChatCellViewModel()
		if (self.sortedMessages.count <= indexPath.row) {
            return messageCellViewModel
        }
		let message = self.sortedMessages[indexPath.row]
		if let outgoing =  message.object(forKey: kOutgoing) as? Bool {
			messageCellViewModel.outgoing = outgoing
		}
		if let unread = message.object(forKey: kUnread) as? Bool {
			messageCellViewModel.unread = unread
		}
		messageCellViewModel.message = message.object(forKey: kMessage) as? String
		messageCellViewModel.date = message.object(forKey: kDate) as? Date
		return messageCellViewModel
	}

}
