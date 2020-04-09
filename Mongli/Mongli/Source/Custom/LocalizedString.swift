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
  case dreamAdverb
  case allTheDreamsAdverb
  case calendarHeaderDateFormat
  case dateFormat

  // Home
  case deleteAllDream

  // Dream
  case createDream
  case deleteDream
  case updateDream

  // Search
  case searchText
  case searchPlaceholder
  case searchFilterText
  case criteria
  case alignment
  case period
  case title
  case content
  case noKeyword
  case newest
  case alphabetically
  case notSelect
  case startDate
  case endDate
  case periodText
  case numberOfDreamsText
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

  func localizedDate(_ date: Date?, _ adVerb: LocalizedString? = nil) -> String {
    guard let date = date else { return "" }

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = self.localized

    if let adVerb = adVerb {
      if isKorean {
        return dateFormatter.string(from: date) + adVerb.localized
      }
      return adVerb.localized + dateFormatter.string(from: date)
    }

    return dateFormatter.string(from: date)
  }
}
