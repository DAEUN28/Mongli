//
//  LocalizedString.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/18.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

enum LocalizedString: String {
  // Basic Error
  case unknownErrorMsg
  case badRequestErrorMsg
  case unauthorizedErrorMsg
  case notFoundErrorMsg
  case serverErrorMsg
  case timeoutErrorMsg

  // Custom Error
  case notFoundUserErrorMsg
  case userConflictErrorMsg
  case notFoundUserForcedLogoutMsg
  case userConflictForcedLogoutMsg

  // Common
  case mongli
  case mongliSubtitle
  case retryMsg

  // Not Localized
  case noContent
}

extension LocalizedString {
  var localized: String {
    return NSLocalizedString(self.rawValue, comment: "")
  }
}
