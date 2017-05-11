//
//  config.swift
//  Anubis
//
//  Created by Daniel Sundström on 2017-05-11.
//  Copyright © 2017 Daniel Sundström. All rights reserved.
//

import Foundation
struct Config {
    // The app URL used to load at start
    static let initialURL = "http://192.168.1.210:8000/index.html";
    // All links not based on this host will be treated as external weblinks
    static let gameHost = "192.168.1.210"
}
