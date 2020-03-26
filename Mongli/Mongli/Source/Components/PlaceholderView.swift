//
//  PlaceholderView.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/25.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import RxSwift
import SnapKit

final class PlaceholderView: UIView {

  enum `Type` {
    case noContent
    case noSearchedContent
  }

  // MARK: UI

  private let imageView = UIImageView().then {
    $0.image = UIImage(.noContentCloud)
    $0.theme.tintColor = themed { $0.primary }
  }
  private let label = UILabel().then {
    $0.setText(.noContentPlaceholder)
    $0.font = FontManager.hpi17L
    $0.theme.textColor = themed { $0.primary }
  }

  // MARK: Initializing

  convenience init(_ type: Type) {
    self.init()
    self.backgroundColor = .clear

    switch type {
    case .noContent: self.label.setText(.noContentPlaceholder)
    case .noSearchedContent: self.label.setText(.noSearchedContentPlaceholder)
    }

    self.addSubview(self.imageView)
    self.addSubview(self.label)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Layout

  override func layoutSubviews() {
    self.label.sizeToFit()

    self.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
    self.imageView.snp.makeConstraints {
      $0.width.equalTo(80)
      $0.height.equalTo(80)
      $0.top.equalToSuperview()
      $0.centerX.equalToSuperview()
    }
    self.label.snp.makeConstraints {
      $0.top.equalTo(self.imageView.snp.bottom)
      $0.centerX.equalToSuperview()
    }
  }
}
