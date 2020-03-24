//
//  LocalizedString.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/18.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

enum LocalizedString: String, Equatable {

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
  case aDreamOfDateFormat
  case allTheDreamsOfDateFormat
  case home
  case search
  case more

  // Category
  case red
  case orange
  case yellow
  case green
  case teal
  case blue
  case indigo
  case purple

  // Home
  case deleteAllDream
  case calendarHeaderDateFormat

  // Not Localized
  case noContent
}

extension LocalizedString {
  var localized: String {
    return NSLocalizedString(self.rawValue, comment: "")
  }

  func localizedDateString(_ string: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = self.localized
    guard let date = dateFormatter.date(from: string) else { return "It's not Date" }
    return dateFormatter.string(from: date)
  }
}
