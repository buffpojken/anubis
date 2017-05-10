//
//  BeaconManager.swift
//  Anubis
//
//  Created by Daniel Sundström on 2017-05-10.
//  Copyright © 2017 Daniel Sundström. All rights reserved.
//

import Foundation
import WebKit
import Buoy

struct ObservedBeacon{
    var payload: Dictionary<String, Any>
    var identifier: String
}

class BeaconManager{

    public var beaconDetected: ((_ beacon: ObservedBeacon) -> Void)?
    
    private var observedBeacons = [ObservedBeacon]();
    private var beaconObserver: Any?;
    
    func registerBeacons(_ beaconList: Array<Dictionary<String, Any>>?, forIdentifier identifier: String){
        if let beacons = beaconList{
            for beacon in beacons{
                print(beacon)
                self.observedBeacons.append(ObservedBeacon(payload: beacon, identifier: identifier))
            }
        }
    }
    
    
    func startObserving(){
        self.beaconObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.buoyDidFindBeacon, object: nil, queue: nil) { (notification) in
            if let userInfo = notification.userInfo{
                let beacon = userInfo[kBUOYBeacon] as! CLBeacon
                self.handleFoundBeacon(beacon: beacon)
            }
        }
    }
    
    
    func stopObserving(){
        if let observer = self.beaconObserver{
            NotificationCenter.default.removeObserver(observer)
            self.beaconObserver = nil;
        }
    }
    
    
    func handleFoundBeacon(beacon: CLBeacon){
        for b in self.observedBeacons{
            let minor = b.payload["minor"] as? Int
            let major = b.payload["major"] as? Int
            if(beacon.major.intValue == major && beacon.minor.intValue == minor){
                self.beaconDetected!(b)
            }
        }
    }
    
}
