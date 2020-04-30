//
//  Keys.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/24.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

enum SFSymbolKey: String, Hashable {
  // Tab bar
  case house
  case magnifyingglass
  case ellipsis

  // Common
  case noContentCloud = "icloud.slash.fill"
  case back = "chevron.left"

  // DreamView
  case calendar

  // Home
  case pencil = "pencil.and.outline"
  case cloud = "cloud.fill"

  // Search
  case filter = "slider.horizontal.3"

  // More
  case menu = "gear"
  case close = "xmark"
  case contact = "envelope.fill"
  case opensourceLisence = "doc.text.fill"
  case accountManagement = "person.fill"
}
