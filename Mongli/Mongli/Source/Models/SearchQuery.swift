//
//  SearchQuery.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/22.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

struct SearchQuery: Codable {
  let page: Int
  let criteria: Int
  let alignment: Int
  let category: Int?
  let period: String?
  let keyword: String?
}

enum Criteria: Int {
  case title = 0
  case content
  case noKeyword

  func toName() -> LocalizedString {
    switch self {
    case .title: return .title
    case .content: return .content
    case .noKeyword: return .noKeyword
    }
  }
}

enum Alignment: Int {
  case newest = 0
  case alphabetically

  func toName() -> LocalizedString {
    switch self {
    case .newest: return .newest
    case .alphabetically: return .alphabetically
    }
  }
}

