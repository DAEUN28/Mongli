//
//  StorageManager.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/17.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation
import Security

import RealmSwift

final class StorageManager {

  // MARK: Shared instance

  static let shared = StorageManager()
  private init() { }

  // MARK: Keychain
  private let account = "Mongli"
  private let service = Bundle.main.bundleIdentifier

  // query
  private lazy var query: [String: Any]? = {
    guard let service = self.service else { return nil }
    return [kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: self.account]
  }()

  func createUser(_ user: User) -> Bool {
    guard let data = try? JSONEncoder().encode(user),
      let service = self.service else { return false }

    let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                kSecAttrService as String: service,
                                kSecAttrAccount as String: self.account,
                                kSecAttrGeneric as String: data]

    if SecItemAdd(query as CFDictionary, nil) != errSecSuccess { return false }
    return true
  }

  func readUser() -> User? {
    guard let service = self.service else { return nil }
    let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                kSecAttrService as String: service,
                                kSecAttrAccount as String: self.account,
                                kSecMatchLimit as String: kSecMatchLimitOne,
                                kSecReturnAttributes as String: true,
                                kSecReturnData as String: true]

    var item: CFTypeRef?
    if SecItemCopyMatching(query as CFDictionary, &item) != errSecSuccess { return nil }

    guard let existingItem = item as? [String: Any],
        let data = existingItem[kSecAttrGeneric as String] as? Data,
        let user = try? JSONDecoder().decode(User.self, from: data) else { return nil }

    return user
  }

  func updateUser(_ user: User) -> Bool {
    guard let query = self.query,
      let data = try? JSONEncoder().encode(user) else { return false }
    let attributes: [String: Any] = [kSecAttrAccount as String: self.account,
                                     kSecAttrGeneric as String: data]

    if SecItemUpdate(query as CFDictionary, attributes as CFDictionary) != errSecSuccess { return false }
    return true
  }

  func deleteUser() -> Bool {
    guard let query = self.query else { return false }
    if SecItemDelete(query as CFDictionary) != errSecSuccess { return false }
    return true
  }

  // MARK: Realm

  private let realm = try! Realm()

  func createAnalysis(_ analysis: Analysis) -> Bool {
    return (try? realm.safeWrite { realm.add(analysis) }) != nil
  }

  func readAnalysis() -> Analysis? {
    return realm.objects(Analysis.self).first
  }

  func updateAnalysis(_ analysis: Analysis) -> Bool {
    let data = self.readAnalysis()
    return (try? realm.safeWrite {
      data?.total = analysis.total
      data?.red = analysis.red
      data?.orange = analysis.orange
      data?.yellow = analysis.yellow
      data?.green = analysis.green
      data?.teal = analysis.teal
      data?.blue = analysis.blue
      data?.indigo = analysis.indigo
      data?.purple = analysis.purple
    }) != nil
  }

  func deleteAnalysis() -> Bool {
    guard let analysis = self.readAnalysis() else { return false }
    return (try? realm.safeWrite { realm.delete(analysis) }) != nil
  }

  // MARK: Common

  func deleteAll() -> Bool {
    return self.deleteUser() && self.deleteAnalysis()
  }
}
