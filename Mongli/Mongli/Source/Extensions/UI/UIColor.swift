//
//  UIColor.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/20.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

extension UIColor {
  convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat) {
    self.init(red: CGFloat(red) / 255.0,
              green: CGFloat(green) / 255.0,
              blue: CGFloat(blue) / 255.0,
              alpha: alpha)
  }

  convenience init(hex: Int, alpha: CGFloat = 1.0) {
    self.init(red: (hex >> 16) & 0xFF,
              green: (hex >> 8) & 0xFF,
              blue: hex & 0xFF,
              alpha: alpha)
  }
}
