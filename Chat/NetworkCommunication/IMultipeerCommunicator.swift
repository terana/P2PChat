//
// Created by terana on 10/05/2018.
// Copyright (c) 2018 Anastasia Terenteva. All rights reserved.
//

import UIKit

protocol IMultipeerCommunicator {
    func sendMessage(string: String, to userID: String, completionHandler: ((_ success: Bool, _ error: Error?) -> ())?)
    weak var delegate: CommunicatorDelegate? { get set }
    var online: Bool { get set }
}
