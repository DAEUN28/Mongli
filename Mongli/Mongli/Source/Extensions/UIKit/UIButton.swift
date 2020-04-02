//
//  UIButton.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/24.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift

extension UIButton {
  func setUnderlineTitle(_ text: LocalizedString) {
    let attributedString = NSMutableAttributedString(string: text.localized)
    attributedString.addAttribute(NSAttributedString.Key.underlineStyle,
                                  value: NSUnderlineStyle.thick.rawValue,
                                  range: NSRange.init(location: 0, length: attributedString.length))
    self.setAttributedTitle(attributedString, for: .normal)
  }

  func setTitle(_ title: LocalizedString) {
    self.setTitle(title.localized, for: .normal)
  }

  func setTheme(_ isEnabled: Bool) {
    if isEnabled {
      self.theme.backgroundColor = themed { $0.buttonEnable }
      self.theme.titleColor(from: themed { $0.buttonEnableTitle }, for: .normal)
    } else {
      self.theme.backgroundColor = themed { $0.buttonDisable }
      self.theme.titleColor(from: themed { $0.buttonDisableTitle }, for: .normal)
    }
  }
}
