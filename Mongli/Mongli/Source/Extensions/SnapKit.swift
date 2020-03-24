//
//  SnapKit.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/24.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import SnapKit

extension ConstraintMakerRelatable {
  @discardableResult
  public func equalToSafeArea(_ rootView: UIView, _ file: String = #file, _ line: UInt = #line)
    -> ConstraintMakerEditable {
    return self.equalTo(rootView.safeAreaLayoutGuide, file, line)
  }
}
