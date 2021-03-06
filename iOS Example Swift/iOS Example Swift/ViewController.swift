//
//  ViewController.swift
//  iOS Example
//
//  Created by Hamilton Chapman on 24/02/2015.
//  Copyright (c) 2015 Pusher. All rights reserved.
//

import UIKit
import PusherSwift

class ViewController: UIViewController, PusherConnectionDelegate {
    var pusher: Pusher! = nil

    @IBAction func connectButton(_ sender: AnyObject) {
        pusher.connect()
    }

    @IBAction func disconnectButton(_ sender: AnyObject) {
        pusher.disconnect()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Only use your secret here for testing or if you're sure that there's
        // no security risk
        let pusherClientOptions = PusherClientOptions(authMethod: .inline(secret: "YOUR_APP_SECRET"))
        pusher = Pusher(key: "YOUR_APP_KEY", options: pusherClientOptions)

        pusher.connection.delegate = self

        pusher.connect()

        let _ = pusher.bind({ (message: Any?) in
            if let message = message as? [String: AnyObject], let eventName = message["event"] as? String, eventName == "pusher:error" {
                if let data = message["data"] as? [String: AnyObject], let errorMessage = data["message"] as? String {
                    print("Error message: \(errorMessage)")
                }
            }
        })

        let onMemberAdded = { (member: PusherPresenceChannelMember) in
            print(member)
        }

        let chan = pusher.subscribe("presence-channel", onMemberAdded: onMemberAdded)

        let _ = chan.bind(eventName: "test-event", callback: { (data: Any?) -> Void in
            print(data)
            let _ = self.pusher.subscribe("presence-channel", onMemberAdded: onMemberAdded)

            if let data = data as? [String : AnyObject] {
                if let testVal = data["test"] as? String {
                    print(testVal)
                }
            }
        })

        // triggers a client event
        chan.trigger(eventName: "client-test", data: ["test": "some value"])
    }

    // PusherConnectionDelegate methods

    func connectionStateDidChange(from old: ConnectionState, to new: ConnectionState) {
        // print the old and new connection states
        print("old: \(old.stringValue()) -> new: \(new.stringValue())")
    }

    func subscriptionDidSucceed(channelName: String) {
        print("Subscribed to \(channelName)")
    }

    func debugLog(message: String) {
        print(message)
    }
}

