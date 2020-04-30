//
//  Font.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/20.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

enum Font {
  // System Font
  case sys9M
  case sys10L
  case sys10R
  case sys10M
  case sys12T
  case sys12L
  case sys12R
  case sys12B
  case sys14L
  case sys14B
  case sys15L
  case sys15B
  case sys16L
  case sys17S

  // 12롯데마트행복
  case hpi12L
  case hpi12M
  case hpi17L
  case hpi20L
  case hpi20B
  case hpi40B
}

extension Font {
  var uifont: UIFont {
    var string = String(describing: self)
    let isSysFont = string.first == "s"
    string.removeFirst(3)

    let weight = self.weight(string.removeLast())
    let size = CGFloat(Int(string)!)

    return isSysFont ? .systemFont(ofSize: size, weight: weight) : UIFont(name: self.name(weight), size: size)!
  }

  private func weight(_ char: Character) -> UIFont.Weight {
    switch char {
    case "T": return .thin
    case "L": return .light
    case "R": return .regular
    case "M": return .medium
    case "B": return .bold
    case "S": return .semibold
    default: return .regular
    }
  }

  private func name(_ weight: UIFont.Weight) -> String {
    switch weight {
    case .light: return "12LotteMartHLight"
    case .medium: return "12LotteMartHappyMedium"
    case .bold: return "12LotteMartHappyBold"
    default: return "12LotteMartHLight"
    }
  }
}
