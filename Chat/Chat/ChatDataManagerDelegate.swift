//
// Created by terana on 22/05/2018.
// Copyright (c) 2018 Anastasia Terenteva. All rights reserved.
//

import UIKit

protocol ChatDataManageDelegate: class {
    func send(message: NSDictionary, toUser receiverUserID: String)
}
