
import UIKit

let kName = "Name"
let kMessages = "Messages"
let kMessage = "Message"
let kOnline = "Online"
let kUnread = "Unread"
let kDate = "Date"
let kSenders = "Senders"

class ChatListDataManager {

	var mainDictionary: NSDictionary

	init() {
		let bundle = Bundle(for: type(of: self))
		self.mainDictionary = NSDictionary()
		guard let mainDictionaryFilePath = bundle.path(forResource: "TestData", ofType: "plist") else { return }
		guard let mainDictionaryFromFile = NSDictionary(contentsOfFile: mainDictionaryFilePath) else { return }
		self.mainDictionary = mainDictionaryFromFile
	}

	var sendersArray: Array<NSDictionary>? {
		return self.mainDictionary.object(forKey: kSenders) as? Array<NSDictionary>
	}

	lazy var offlineSenders: Array<NSDictionary> = {
		return self.senders(online: false)
	}()

	lazy var onlineSenders: Array<NSDictionary> = {
		return self.senders(online: true)
	}()

	private func senders(online: Bool) -> Array<NSDictionary> {
		let result = self.sendersArray?.flatMap({ (element) -> NSDictionary? in
			if let isOnline = element.object(forKey: kOnline) as? Bool {
				return isOnline == online ? element : nil
			}
			return nil
		})
		if let result = result {
			return result.sorted(by: { (element1, element2) -> Bool in
				if let date1 = element1.object(forKey: kDate) as? Date, let date2 = element2.object(forKey: kDate) as? Date {
					return date1.timeIntervalSince(date2) >= 0
				}
				return false
			})
		} else {
			return Array()
		}
	}

	var hasOnlineSenders: Bool {
		return onlineSenders.count > 0
	}

	var hasOfflineSenders: Bool {
		return offlineSenders.count > 0
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

}
