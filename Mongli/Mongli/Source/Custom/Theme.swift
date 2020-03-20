//
//  Theme.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/20.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import RxSwift
import RxTheme

protocol Theme {
  // Primary Palette
  var primary: UIColor { get }
  var assistant: UIColor { get }

  // Category Palette
  var red: UIColor { get }
  var orange: UIColor { get }
  var yellow: UIColor { get }
  var green: UIColor { get }
  var teal: UIColor { get }
  var blue: UIColor { get }
  var indigo: UIColor { get }
  var purple: UIColor { get }

  // Util Palette
  var background: UIColor { get }
  var text: UIColor { get }
  var buttonEnable: UIColor { get }
  var buttonDisable: UIColor { get }
  var placeholder: UIColor { get }
  var gradient: CAGradientLayer { get }
}

extension Theme {
  var red: UIColor { .init(hex: 0xFF6C64) }
  var orange: UIColor { .init(hex: 0xFF9F0A) }
  var yellow: UIColor { .init(hex: 0xFFD60A) }
  var green: UIColor { .init(hex: 0x32D74B) }
  var teal: UIColor { .init(hex: 0x64D2FF) }
  var blue: UIColor { .init(hex: 0x2491FF) }
  var indigo: UIColor { .init(hex: 0x5E5CE6) }
  var purple: UIColor { .init(hex: 0xBF5AF2) }

  var buttonEnable: UIColor { self.primary }
  var buttonDisable: UIColor { .clear }

  var gradient: CAGradientLayer {
    let gradient = CAGradientLayer()
    gradient.colors = [ self.assistant.cgColor, self.primary.cgColor ]
    return gradient
  }
}

struct LightTheme: Theme {
  var primary: UIColor { .init(hex: 0x3F2B96) }
  var assistant: UIColor { .init(hex: 0xA8C0FF) }
  var background: UIColor { .white }
  var text: UIColor { .init(hex: 0x404040) }
  var placeholder: UIColor { .init(hex: 0xD3D3D3) }
}

struct DarkTheme: Theme {
  var primary: UIColor { .init(hex: 0xA8C0FF) }
  var assistant: UIColor { .init(hex: 0x3F2B96) }
  var background: UIColor { .init(hex: 0x1C1C1D, alpha: 0.94) }
  var text: UIColor { .white }
  var placeholder: UIColor { .init(hex: 0x959595) }
}

enum ThemeType: ThemeProvider {
  case light, dark

  var associatedObject: Theme {
    switch self {
    case .light: return LightTheme()
    case .dark: return DarkTheme()
    }
  }
}

let themeService = ThemeType.service(initial: .light)
func themed<T>(_ mapper: @escaping ((Theme) -> T)) -> Observable<T> {
  return themeService.attrStream(mapper)
}
