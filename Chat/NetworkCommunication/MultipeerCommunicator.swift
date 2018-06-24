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
let waitTimeout = TimeInterval(130)

class MultipeerCommunicator: NSObject, IMultipeerCommunicator,
        MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate {

    weak var delegate: CommunicatorDelegate?
    var online: Bool

    var multipeerAdvertiser: MCNearbyServiceAdvertiser!
    var multipeerBrowser: MCNearbyServiceBrowser!
    var sessionsByPeerID = Dictionary<String, MCSession>()
    var peerIDByUserID = Dictionary<String, MCPeerID>()

    let myPeerID = MCPeerID(displayName: "terana")
    let myUserName = "Anastasiia"


    override init() {
        online = true
        super.init()

        let serviceType = "simple-app"

        multipeerAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID,
                discoveryInfo: [kUserName: myUserName], serviceType: serviceType)
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

    private func removeUser(withPeerID peerID: MCPeerID) {
        delegate?.didLostUser(userID: peerID.displayName)
        sessionsByPeerID.removeValue(forKey: peerID.displayName)
        peerIDByUserID.removeValue(forKey: peerID.displayName)
    }

    // MARK: IMultipeerCommunicator

    func sendMessage(string: String, to userID: String, completionHandler: ((_ success: Bool, _ error: Error?) -> ())?) {
        guard let session = sessionsByPeerID[userID] else {
            print("Failed to send message to \(userID)")
            completionHandler?(false, nil)
            return
        }
        guard let peerID = peerIDByUserID[userID] else {
            print("Failed to send message to \(userID)")
            completionHandler?(false, nil)
            return
        }
        let msg = [kEventType: "TextMessage",
                   kMessageId: generateMessageId(),
                   kText: string]
        do {
            try session.send(JSONSerialization.data(withJSONObject: msg),
                    toPeers: [peerID], with: MCSessionSendDataMode.unreliable)
        } catch let error {
            print("### Failed to send message \(error)")
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
        if sessionsByPeerID[peerID.displayName] != nil {
            invitationHandler(true, nil)
        } else {
            let session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.none)
            session.delegate = self
            sessionsByPeerID[peerID.displayName] = session
            peerIDByUserID[peerID.displayName] = peerID
            invitationHandler(true, session)
        }

        do {
            guard let context = context else {
                delegate?.didFoundUser(userID: peerID.displayName, userName: "NoName")
                return
            }
            let json = try JSONSerialization.jsonObject(with: context, options: []) as? Dictionary<String, String>
            if let userName = json?[kUserName] {
                delegate?.didFoundUser(userID: peerID.displayName, userName: userName)
            }
        } catch let error {
            print(error)
        }
    }

    // MARK: MCNearbyServiceBrowserDelegate

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        delegate?.failedToStartBrowsingForUsers(error: error)
    }

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        var invitationContext: Data?
        do {
            invitationContext = try JSONSerialization.data(withJSONObject: [kUserName: myUserName])
        } catch let error {
            print("Failed to encode invitation context\n\(error)")
        }

        if let session = sessionsByPeerID[peerID.displayName] {
            multipeerBrowser.invitePeer(peerID, to: session, withContext: invitationContext, timeout: waitTimeout)
        } else {
            let session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.none)
            session.delegate = self
            sessionsByPeerID[peerID.displayName] = session
            peerIDByUserID[peerID.displayName] = peerID
            multipeerBrowser.invitePeer(peerID, to: session, withContext: invitationContext, timeout: waitTimeout)
        }

        if let info = info {
            if let userName = info[kUserName] {
                delegate?.didFoundUser(userID: peerID.displayName, userName: userName)
            } else {
                delegate?.didFoundUser(userID: peerID.displayName, userName: "NoName")
            }
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        removeUser(withPeerID: peerID)
    }

    // MARK: MCSessionDelegate

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            let message = try JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, String>
            if let text = message?[kText] {
                delegate?.didReceiveMessage(text: text, fromUser: peerID.displayName, toUser: myPeerID.displayName)
            } else {
                print("### FAILED to find text in message ###\n \(message ?? [:])")
            }
        } catch let error {
            print("### FAILED to receive message ###\n \(error)")
        }

    }

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("### Session connected to user \(peerID.displayName)")
        case MCSessionState.connecting:
            print("### Session is connecting to user \(peerID.displayName)")
        case MCSessionState.notConnected:
            removeUser(withPeerID: peerID)
            print("### Session disconnected from user \(peerID.displayName)")
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

    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID,
                 certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true);
    }
}

