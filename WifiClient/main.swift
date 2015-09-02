//
//  main.swift
//  WifiClient
//
//  Created by Feng Ding on 8/5/15.
//  Copyright (c) 2015 Feng Ding. All rights reserved.
//

import Foundation
import Cocoa
import CoreWLAN

func help() {
    println("Help:")
    println("Open       : WifiClient <ssid>")
    println("Personal   : WifiClient <ssid> <password>")
    println("Enterprise : WifiClient <ssid> <username> <password>")
    println("           : WifiClient <ssid> tls <common name>")
}
func getSecIdentity(sub: String) -> SecIdentityRef? {
    var dataTypeRef: Unmanaged<AnyObject>?
    let keychainQuery: [NSString: NSString] = [kSecClass: kSecClassIdentity, kSecMatchLimit: kSecMatchLimitOne, kSecMatchSubjectContains: sub]
    let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
    if let opaque = dataTypeRef?.toOpaque() {
        return (dataTypeRef?.takeUnretainedValue() as! SecIdentityRef)
    } else {
        return nil
    }
}
if (Process.argc > 4 || Process.argc < 2) {
    help()
    exit(1)
}


let ssid = Process.arguments[1]
let wirelessClient = CWWiFiClient()
let wirelessInterface = wirelessClient.interface()
wirelessInterface.disassociate()
let myNetworks = wirelessInterface.scanForNetworksWithName(ssid, error: nil)
if myNetworks.count == 0 {
    println("I cannot find this ssid \(ssid)")
    exit(1)
}
switch Process.argc {
case 2:
    wirelessInterface.associateToNetwork(myNetworks.first as! CWNetwork, password: nil, error: nil)
case 3:
    let password = Process.arguments[2]
    wirelessInterface.associateToNetwork(myNetworks.first as! CWNetwork, password: password, error: nil)
case 4:
    let username = Process.arguments[2]
    let password = Process.arguments[3]
    if username == "tls" {
        if let secId = getSecIdentity(password) {
            wirelessInterface.associateToEnterpriseNetwork(myNetworks.first as! CWNetwork, identity: secId, username: nil, password: nil, error: nil)
        } else {
            println("No matching certificate in the machine.")
        }
    } else {
        wirelessInterface.associateToEnterpriseNetwork(myNetworks.first as! CWNetwork, identity: nil, username: username, password: password, error: nil)
    }
default:
    help()
    exit(1)
}


