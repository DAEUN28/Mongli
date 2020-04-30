//
//  BottomButton.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/04/02.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

final class BottomButton: UIButton {

  convenience init(_ title: LocalizedString) {
    self.init()
    self.setTitle(title)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.titleLabel?.setFont(.hpi17L)
    self.theme.backgroundColor = themed { $0.primary }
    self.theme.titleColor(from: themed { $0.background }, for: .normal)
    self.layer.cornerRadius = 12

    self.snp.makeConstraints {
      $0.height.equalTo(44)
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
