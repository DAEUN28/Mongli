//
//  DatabaseManager.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/17.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

import RealmSwift

struct DatabaseManager {
  enum DataType {
    case info, analysis
  }

  static var realm = try! Realm()

  static func create(_ object: Object) throws {
    try realm.safeWrite {
      realm.add(object)
    }
  }

  static func read(_ type: DataType) -> Object? {
    switch type {
    case .info: return realm.objects(UserInfo.self).first
    case .analysis: return realm.objects(UserAnalysis.self).first
    }
  }

  static func update(_ type: DataType, object: Object) throws {
    var data = self.read(type)
    try realm.safeWrite {
      data = object
    }
  }

  static func delete(_ object: Object) throws {
    try realm.safeWrite {
      realm.delete(object)
    }
  }

  static func deleteAll() throws {
    try realm.safeWrite {
      realm.deleteAll()
    }
  }
}
