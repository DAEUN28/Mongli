//
//  UIAlertAction.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/04/25.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

extension UIAlertAction {
  convenience init(title: LocalizedString? = nil,
                   style: UIAlertAction.Style,
                   handler: ((UIAlertAction) -> Void)? = nil) {
    self.init(title: title?.localized, style: style, handler: handler)
  }
}
