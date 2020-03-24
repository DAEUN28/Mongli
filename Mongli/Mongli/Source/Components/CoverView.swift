//
//  CoverView.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/23.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import RxSwift
import SnapKit
import Then

final class CoverView: UIView {

  // MARK: UI

  let label = UILabel().then {
    $0.setText(.aDreamOfDateFormat)
    $0.font = FontManager.hpi20L
    $0.textAlignment = .left
    $0.theme.textColor = themed { $0.primary }
  }
  let button = UIButton().then {
    $0.setUnderlineTitle(.deleteAllDream)
    $0.titleLabel?.font = FontManager.sys12L
    $0.titleLabel?.textAlignment = .right
    $0.titleLabel?.theme.textColor = themed { $0.primary }
  }

  // MARK: Initializing

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.clipsToBounds = true
    self.layer.cornerRadius = 40
    self.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)

    self.theme.backgroundColor = themed { $0.background }

    self.addSubview(label)
    self.addSubview(button)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Layout

  override func layoutSubviews() {
    self.label.sizeToFit()
    self.button.sizeToFit()

    self.label.snp.makeConstraints {
      $0.top.equalToSuperview().inset(24)
      $0.leading.equalToSuperview().inset(28)
    }
    self.button.snp.makeConstraints {
      $0.bottomMargin.equalTo(self.label.snp.bottom)
      $0.trailing.equalToSuperview().inset(32)
    }
  }
}
