//
//  Spinner.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/25.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import RxSwift
import SnapKit

final class Spinner: UIView {

  // MARK: UI

  let indicator: UIActivityIndicatorView = .init()

  // MARK: Initializing

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.theme.backgroundColor = themed { $0.background.withAlphaComponent(0.5) }
    
    self.addSubview(self.indicator)

    self.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.width.equalTo(80)
      $0.height.equalTo(80)
    }
    self.indicator.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.width.equalTo(40)
      $0.height.equalTo(40)
    }
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
