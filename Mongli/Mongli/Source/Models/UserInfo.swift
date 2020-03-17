//
//  UserInfo.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/16.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

import RealmSwift

class UserInfo: Object, Codable {
  @objc dynamic var uid: String?
  @objc dynamic var name: String?
  @objc dynamic var token: Token?
}
