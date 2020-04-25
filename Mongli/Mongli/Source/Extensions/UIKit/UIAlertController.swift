//
//  UIAlertController.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/04/25.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

extension UIAlertController {
  convenience init(title: LocalizedString? = nil,
                   message: LocalizedString? = nil,
                   style: UIAlertController.Style) {
    self.init(title: title?.localized, message: message?.localized, preferredStyle: style)
  }

  func setTitle(title: LocalizedString) {
    self.title = title.localized
  }

  func setMessage(message: LocalizedString) {
    self.message = message.localized
  }
}
