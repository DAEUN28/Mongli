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

final class CoverView: UIView {

  // MARK: UI

  let label = UILabel().then {
    $0.text = LocalizedString.dateFormat.localizedDate(Date(), .dreamAdverb)
    $0.setFont(.hpi20L)
    $0.textAlignment = .left
    $0.theme.textColor = themed { $0.primary }
  }
  let button = UIButton().then {
    $0.setUnderlineTitle(.deleteAllDream)
    $0.titleLabel?.setFont(.sys12L)
    $0.titleLabel?.textAlignment = .right
    $0.titleLabel?.theme.textColor = themed { $0.primary }
  }

  // MARK: Initializing

  override init(frame: CGRect) {
    super.init(frame: frame)
    clipsToBounds = true
    layer.cornerRadius = 40
    layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)

    theme.backgroundColor = themed { $0.background }

    addSubview(label)
    addSubview(button)
    self.setupConstraints()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Layout

  func setupConstraints() {
    label.snp.makeConstraints {
      $0.top.equalToSuperview().inset(24)
      $0.leading.equalToSuperview().inset(28)
    }
    button.snp.makeConstraints {
      $0.height.equalTo(button.intrinsicContentSize.height)
      $0.bottomMargin.equalTo(label.snp.bottom)
      $0.trailing.equalToSuperview().inset(32)
    }
  }
}
