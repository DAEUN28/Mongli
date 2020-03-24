//
//  UIButton.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/24.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

extension UIButton {
  func setUnderlineTitle(_ text: LocalizedString) {
    let attributedString = NSMutableAttributedString(string: text.localized)
    attributedString.addAttribute(NSAttributedString.Key.underlineStyle,
                                  value: NSUnderlineStyle.thick.rawValue,
                                  range: NSRange.init(location: 0, length: attributedString.length))
    self.setAttributedTitle(attributedString, for: .normal)
  }
}
