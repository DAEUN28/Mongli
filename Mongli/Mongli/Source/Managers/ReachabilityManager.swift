//
//  ReachabilityManager.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/23.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

import Alamofire

struct ReachabilityManager {
  static func isConnected() -> Bool {
    return NetworkReachabilityManager()!.isReachable
  }
}
