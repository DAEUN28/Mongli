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
  case cancel
  case delete
  case select
  case done
  case `continue`
  case close
  case retryMsg
  case deletedMsg
  case deleteDreamDesc
  case cancelDreamDesc

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
  case category
  case categoryInfoText
  case categoryInfoDesc
  case red
  case orange
  case yellow
  case green
  case teal
  case blue
  case indigo
  case purple
  case redText
  case orangeText
  case yellowText
  case greenText
  case tealText
  case blueText
  case indigoText
  case purpleText

  // DateFormat
  case calendarHeaderDateFormat
  case aDreamOfDateFormat
  case allTheDreamsOfDateFormat

  // Home
  case deleteAllDream

  // Dream
  case createDream
  case deleteDream
  case updateDream
  case selectDateText

  // Search
  case searchText
  case searchPlaceholder
  case searchFilterText
  case criteria
  case alignment
  case title
  case content
  case noKeyword
  case newest
  case alphabetically
  case filterApplyText
}

extension LocalizedString {
  var localized: String {
    return NSLocalizedString(self.rawValue, comment: "")
  }

  private var isKorean: Bool {
    switch Locale.current.languageCode {
    case "ko", "ko_KR": return true
    default: return false
    }
  }

  func localizedDate(_ date: Date?) -> String {
    guard let date = date else { return "" }

    let dateFormatter = DateFormatter()

    if self.isKorean {
      dateFormatter.dateFormat = self.localized
      return dateFormatter.string(from: date)
    } else {
      dateFormatter.dateFormat = "MMMM d, yyyy"
      return self.localized + dateFormatter.string(from: date)
    }
  }
}
