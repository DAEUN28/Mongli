//
//  LocalizedString.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/18.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

enum LocalizedString: String, Equatable, Hashable {

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
  case deletedMsg
  case cancel
  case delete
  case select
  case done
  case deleteDreamDesc
  case category
  case categoryInfoText

  // Tab bar
  case home
  case search
  case more

  // Placeholder
  case noContentPlaceholder
  case noSearchedContentPlaceholder
  case dreamTitlePlaceholder
  case dreamContentPlaceholder

  // Category
  case red
  case orange
  case yellow
  case green
  case teal
  case blue
  case indigo
  case purple

  // DateFormat
  case calendarHeaderDateFormat
  case aDreamOfDateFormat
  case allTheDreamsOfDateFormat

  // Home
  case deleteAllDream

  // Create Dream
  case createDream
  case selectDateText

  // Read Dream
  case deleteDreamText
  case updateDreamText
}

extension LocalizedString {
  var localized: String {
    return NSLocalizedString(self.rawValue, comment: "")
  }

  func localizedDateString(_ string: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = self.localized
    guard let date = dateFormatter.date(from: string) else { return string }
    return dateFormatter.string(from: date)
  }

  func localizedDate(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = self.localized
    return dateFormatter.string(from: date)
  }
}
