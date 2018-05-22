//
// Created by terana on 10/05/2018.
// Copyright (c) 2018 Anastasia Terenteva. All rights reserved.
//

import UIKit
import MultipeerConnectivity

let kText = "text"
let kUserName = "userName"
let kEventType = "eventType"
let kMessageId = "messageId"
let waitTimeout = TimeInterval(30)

class MultipeerCommunicator: NSObject, IMultipeerCommunicator,
        MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate {

    weak var delegate: CommunicatorDelegate?
    var online: Bool

    var multipeerAdvertiser: MCNearbyServiceAdvertiser!
    var multipeerBrowser: MCNearbyServiceBrowser!
    var sessionsByPeerID = Dictionary<String, MCSession>()

    let myPeerID = MCPeerID(displayName: "terana")

    override init() {
        online = true
        super.init()

        let serviceType = "simple-app"

        multipeerAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID,
                discoveryInfo: [kUserName: "terana"], serviceType: serviceType)
        multipeerAdvertiser.delegate = self
        multipeerAdvertiser.startAdvertisingPeer()

        multipeerBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        multipeerBrowser.delegate = self
        multipeerBrowser.startBrowsingForPeers()
    }


    func generateMessageId() -> String {
        let string = "\(arc4random_uniform(UINT32_MAX))+\(Date.timeIntervalSinceReferenceDate)+\(arc4random_uniform(UINT32_MAX))"
                .data(using: .utf8)?.base64EncodedString()
        return string!
    }


    // MARK: IMultipeerCommunicator

    func sendMessage(string: String, to userID: String, completionHandler: ((_ success: Bool, _ error: Error?) -> ())?) {
        guard let session = sessionsByPeerID[userID] else {
            print("Failed to send message to \(userID)")
            completionHandler?(false, nil)
            return
        }
        let msg = [kEventType: "TextMessage",
                   kMessageId: generateMessageId(),
                   kText: string]
        do {
            try session.send(JSONSerialization.data(withJSONObject: msg),
                    toPeers: session.connectedPeers, with: MCSessionSendDataMode.reliable)
        } catch let error {
            print(error)
            completionHandler?(false, error)
        }
        completionHandler?(true, nil)
    }

    // MARK: MCNearbyServiceAdvertiserDelegate
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        delegate?.failedToStartAdvertising(error: error)
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, nil)
//        do {
//            guard let context = context else {
//                delegate?.didFoundUser(userID: peerID.displayName, userName: "NoName")
//                return
//            }
//
//            let json = try JSONSerialization.jsonObject(with: context, options: []) as? Dictionary<String, String>
//            if let userName = json?[kUserName] {
//                delegate?.didFoundUser(userID: peerID.displayName, userName: userName)
//            }
//        } catch let error {
//            print(error)
//        }

    }

    // MARK: MCNearbyServiceBrowserDelegate
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        delegate?.failedToStartBrowsingForUsers(error: error)
    }

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        let session = MCSession(peer: peerID)
        session.delegate = self
        sessionsByPeerID[peerID.displayName] = session
        multipeerBrowser.invitePeer(peerID, to: session, withContext: nil, timeout: waitTimeout)

        if let info = info {
            if let userName = info[kUserName] {
                delegate?.didFoundUser(userID: peerID.displayName, userName: userName)
            }
        }

        delegate?.didFoundUser(userID: peerID.displayName, userName: "NoName")
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        sessionsByPeerID.removeValue(forKey: peerID.displayName)
        delegate?.didLostUser(userID: peerID.displayName)
    }

    // MARK: MCSessionDelegate

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            let message = try JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, String>
            if let text = message?["text"] {
                delegate?.didReceiveMessage(text: text, fromUser: peerID.displayName, toUser: myPeerID.displayName)
            }
        } catch let error {
            print(error)
        }

    }

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            delegate?.didFoundUser(userID: peerID.displayName, userName: peerID.displayName)
        case MCSessionState.notConnected:
            delegate?.didLostUser(userID: peerID.displayName)
        default:
            break
        }
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {

    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String,
                 fromPeer peerID: MCPeerID) {

    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID, with progress: Progress) {

    }

}

