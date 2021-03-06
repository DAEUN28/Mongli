//
//  FloatingButton.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/04/15.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

final class FloatingItem: UIButton {

  init(_ category: Category) {
    self.category = category

    super.init(frame: .zero)

    self.setTitle(category.toName().localized, for: .normal)
    self.titleLabel?.font = FontManager.sys10M
    self.titleLabel?.textAlignment = .center
    self.theme.backgroundColor = themed { $0.background }
    self.setTitleColor(category.toColor(), for: .normal)
    self.layer.cornerRadius = 3

    self.snp.makeConstraints {
      $0.height.equalTo(20)
    }
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
