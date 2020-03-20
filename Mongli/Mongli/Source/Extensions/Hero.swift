//
//  Hero.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/20.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

import Hero

extension HeroExtension where Base: UIView {
  func setID(_ id: HeroID) {
    self.id = id.rawValue
  }
}
