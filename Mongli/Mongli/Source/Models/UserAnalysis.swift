//
//  UserAnalysis.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/16.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

import RealmSwift

class UserAnalysis: Object, Codable {
  @objc dynamic var total: Int = 0
  @objc dynamic var red: Int = 0
  @objc dynamic var orange: Int = 0
  @objc dynamic var yellow: Int = 0
  @objc dynamic var green: Int = 0
  @objc dynamic var teal: Int = 0
  @objc dynamic var blue: Int = 0
  @objc dynamic var indigo: Int = 0
  @objc dynamic var purple: Int = 0
}

