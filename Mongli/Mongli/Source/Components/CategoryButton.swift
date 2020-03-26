//
//  CategoryButton.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/26.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

final class CategoryButton: UIButton {
  
  convenience init(_ category: Category) {
    self.init()

    self.setTitle(category.toName().localized, for: .normal)
    self.titleLabel?.font = FontManager.sys10M
    self.titleLabel?.textAlignment = .center
    self.theme.backgroundColor = themed { $0.background }
    self.tintColor = category.toColor()
    self.layer.cornerRadius = 3
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
