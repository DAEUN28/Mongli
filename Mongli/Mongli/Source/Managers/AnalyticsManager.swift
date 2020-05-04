//
//  AnalyticsManager.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/05/04.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import FirebaseAnalytics

// swiftlint:disable identifier_name
enum AnalyticsManager: String {
  case view_signIn
  case view_categoryInfo
  case view_readDream
  case view_updateDream
  case view_deleteDream
  case view_createDream
  case view_home
  case view_deleteAllDream
  case view_search
  case view_search_filter
  case view_more
  case view_more_menu
  case view_more_menu_opensourceLisence
  case view_more_menu_accountManagement
  case view_more_menu_contact
  case view_more_menu_accountManagement_rename
  case view_more_menu_accountManagement_logout
  case view_more_menu_accountManagement_deleteUser
}

extension AnalyticsManager {
  func log(_ screenClass: String?) {
    Analytics.setScreenName(self.rawValue, screenClass: screenClass)
  }

  static func setUserID() {
    if let id = TokenManager.userID() {
      Analytics.setUserID("\(id)")
    }
  }
}
