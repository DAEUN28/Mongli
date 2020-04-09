//
//  Category.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/24.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

enum Category: Int {
  case red = 0
  case orange
  case yellow
  case green
  case teal
  case blue
  case indigo
  case purple

  init?(_ rawValue: Int?) {
    guard let rawValue = rawValue else { return nil }
    self.init(rawValue)
  }
}

extension Category {
  static let categories: [Category] = [.red, .orange, .yellow, .green, .teal, .blue, .indigo, .purple]

  func toColor() -> UIColor {
    switch self {
    case .red: return .init(hex: 0xFF6C64)
    case .orange: return .init(hex: 0xFF9F0A)
    case .yellow: return .init(hex: 0xFFD60A)
    case .green: return .init(hex: 0x32D74B)
    case .teal: return .init(hex: 0x64D2FF)
    case .blue: return .init(hex: 0x2491FF)
    case .indigo: return .init(hex: 0x5E5CE6)
    case .purple: return .init(hex: 0xBF5AF2)
    }
  }

  func toName() -> LocalizedString {
    switch self {
    case .red: return .red
    case .orange: return .orange
    case .yellow: return .yellow
    case .green: return .green
    case .teal: return .teal
    case .blue: return .blue
    case .indigo: return .indigo
    case .purple: return .purple
    }
  }

  func toText() -> LocalizedString {
    switch self {
    case .red: return .redText
    case .orange: return .orangeText
    case .yellow: return .yellowText
    case .green: return .greenText
    case .teal: return .tealText
    case .blue: return .blueText
    case .indigo: return .indigoText
    case .purple: return .purpleText
    }
  }
}
