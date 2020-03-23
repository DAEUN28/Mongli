//
//  User.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/16.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

struct User: Codable {
  var uid: String
  var name: String
  var token: Token
}
