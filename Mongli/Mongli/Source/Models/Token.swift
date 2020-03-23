//
//  Token.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/16.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

struct Token: Codable {
  var accessToken: String
  var refreshToken: String
}
