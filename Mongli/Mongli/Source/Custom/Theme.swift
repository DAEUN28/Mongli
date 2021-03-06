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

  // Util Palette
  var background: UIColor { get }
  var text: UIColor { get }
  var buttonEnable: UIColor { get }
  var buttonDisable: UIColor { get }
  var buttonEnableTitle: UIColor { get }
  var buttonDisableTitle: UIColor { get }
  var placeholder: UIColor { get }
  var logoText: UIColor { get }
  var darkWhite: UIColor { get }
  var red: UIColor { get }

  var navigationBarTitle: [NSAttributedString.Key: Any] { get }
  var segmentedControlTitle: [NSAttributedString.Key: Any] { get }
  var categoryInfoDesc: NSMutableAttributedString { get }
  var gradient: CAGradientLayer { get }
}

extension Theme {
  var buttonEnable: UIColor { self.background }
  var buttonDisable: UIColor { .clear }
  var buttonEnableTitle: UIColor { self.primary }
  var buttonDisableTitle: UIColor { self.background }
  var logoText: UIColor { .init(hex: 0x404040) }
  var red: UIColor { .init(hex: 0xE74C3C) }

  var navigationBarTitle: [NSAttributedString.Key: Any] {
    [.font: Font.hpi17L.uifont, .foregroundColor: self.darkWhite]
  }
  var segmentedControlTitle: [NSAttributedString.Key: Any] {
    [.foregroundColor: self.placeholder]
  }
  var categoryInfoDesc: NSMutableAttributedString {
    let text = LocalizedString.categoryInfoDesc.localized as NSString
    let string = NSMutableAttributedString(string: text as String)
    string.addAttributes([.foregroundColor: self.primary],
                         range: text.range(of: LocalizedString.mongli.localized))
    string.addAttributes([.foregroundColor: self.primary],
                         range: text.range(of: LocalizedString.category.localized))
    string.addAttributes([.foregroundColor: self.primary],
                         range: text.range(of: LocalizedString.eightDreams.localized))
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = 10
    string.addAttributes([.paragraphStyle: paragraphStyle], range: text.range(of: text as String))
    return string
  }
  var gradient: CAGradientLayer {
    let gradient = CAGradientLayer()
    gradient.colors = [ self.assistant.cgColor, self.primary.cgColor ]
    gradient.locations = [0.0, 1.0]
    return gradient
  }
}

struct LightTheme: Theme {
  var primary: UIColor { .init(hex: 0x3F2B96) }
  var assistant: UIColor { .init(hex: 0xA8C0FF) }
  var background: UIColor { .white }
  var text: UIColor { .init(hex: 0x404040) }
  var darkWhite: UIColor { .white }
  var placeholder: UIColor { .init(hex: 0xD3D3D3) }
}

struct DarkTheme: Theme {
  var primary: UIColor { .init(hex: 0xA8C0FF) }
  var assistant: UIColor { .init(hex: 0x3F2B96) }
  var background: UIColor { .init(hex: 0x1C1C1D) }
  var text: UIColor { .white }
  var darkWhite: UIColor { .init(hex: 0xD3D3D3) }
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
