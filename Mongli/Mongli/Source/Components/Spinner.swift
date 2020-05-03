//
//  Spinner.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/25.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import RxSwift

final class Spinner: UIView {

  // MARK: UI

  let indicator: UIActivityIndicatorView = .init()

  // MARK: Initializing

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.layer.cornerRadius = 10
    self.theme.backgroundColor = themed { $0.primary.withAlphaComponent(0.5) }

    self.addSubview(self.indicator)
    self.setupConstraints()
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Layout

  func setupConstraints() {
    self.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.width.equalTo(80)
      $0.height.equalTo(80)
    }
    indicator.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.width.equalTo(40)
      $0.height.equalTo(40)
    }
  }
}
