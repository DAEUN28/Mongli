//
//  UIImage.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/24.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

extension UIImage {
  convenience init?(_ sfSymbolKey: SFSymbolKey) {
    self.init(systemName: sfSymbolKey.rawValue)
  }
}
