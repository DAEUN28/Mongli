//
//  FontManager.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/20.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

struct FontManager {
  // System Font
  static let sys9M = UIFont.systemFont(ofSize: 9, weight: .medium)
  static let sys10L = UIFont.systemFont(ofSize: 10, weight: .light)
  static let sys10R = UIFont.systemFont(ofSize: 10, weight: .regular)
  static let sys10M = UIFont.systemFont(ofSize: 10, weight: .medium)
  static let sys12T = UIFont.systemFont(ofSize: 12, weight: .thin)
  static let sys12L = UIFont.systemFont(ofSize: 12, weight: .light)
  static let sys12R = UIFont.systemFont(ofSize: 12, weight: .regular)
  static let sys12B = UIFont.systemFont(ofSize: 12, weight: .bold)
  static let sys14L = UIFont.systemFont(ofSize: 14, weight: .light)
  static let sys14B = UIFont.systemFont(ofSize: 14, weight: .bold)
  static let sys15L = UIFont.systemFont(ofSize: 15, weight: .light)
  static let sys15B = UIFont.systemFont(ofSize: 15, weight: .bold)
  static let sys17SB = UIFont.systemFont(ofSize: 17, weight: .semibold)

  // 12롯데마트행복
  static let hpi12L = UIFont(name: "12LotteMartHappyMedium", size: 12)!
  static let hpi12M = UIFont(name: "12LotteMartHappyMedium", size: 12)!
  static let hpi17L = UIFont(name: "12LotteMartHLight", size: 17)!
  static let hpi20L = UIFont(name: "12LotteMartHLight", size: 20)!
  static let hpi20B = UIFont(name: "12LotteMartHappyBold", size: 20)!
  static let hpi40B = UIFont(name: "12LotteMartHappyBold", size: 40)!
}
