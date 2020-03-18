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

  static func create(_ object: Object) -> Bool {
    return (try? realm.safeWrite { realm.add(object) }) != nil
  }

  static func read(_ type: DataType) -> Object? {
    switch type {
    case .info: return realm.objects(UserInfo.self).first
    case .analysis: return realm.objects(UserAnalysis.self).first
    }
  }

  static func update(_ type: DataType, object: Object) -> Bool {
    var data = self.read(type)
    return (try? realm.safeWrite { data = object }) != nil
  }

  static func delete(_ object: Object) -> Bool {
    return (try? realm.safeWrite { realm.delete(object) }) != nil
  }

  static func deleteAll() -> Bool {
    return (try? realm.safeWrite { realm.deleteAll() }) != nil
  }
}
