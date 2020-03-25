//
//  LogoView.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/20.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import RxSwift
import SnapKit

final class LogoView: UIView {

  // MARK: UI

  private let titleLabel = UILabel().then {
    $0.setText(.mongli)
    $0.font = FontManager.hpi40B
    $0.theme.textColor = themed { $0.logoText }
  }
  private let subtitleLabel = UILabel().then {
    $0.setText(.mongliSubtitle)
    $0.font = FontManager.hpi12M
    $0.theme.textColor = themed { $0.logoText }
  }

  // MARK: Initializing

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.layer.cornerRadius = 100
    self.backgroundColor = .clear

    self.addSubview(titleLabel)
    self.addSubview(subtitleLabel)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Layout

  override func layoutSubviews() {
    self.titleLabel.sizeToFit()
    self.subtitleLabel.sizeToFit()

    self.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.height.equalTo(200)
      $0.width.equalTo(200)
    }

    self.titleLabel.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
    self.subtitleLabel.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalTo(self.titleLabel.snp.bottom).offset(8)
    }
  }
}
