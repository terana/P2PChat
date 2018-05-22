//
// Created by terana on 21/05/2018.
// Copyright (c) 2018 Anastasia Terenteva. All rights reserved.
//

import UIKit

protocol ChatListDataManager: class {
    func messagesForIndexPath(indexPath: IndexPath) -> [NSDictionary]
    func nameForIndexPath(indexPath: IndexPath) -> String
    func conversationCellViewModelForIndexPath(indexPath: IndexPath) -> ChatListCellViewModel
}
