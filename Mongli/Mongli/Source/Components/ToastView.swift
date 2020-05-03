//
//  ToastView.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/23.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

final class ToastView: UIView {

  // MARK: UI

  private let label = UILabel().then {
    $0.setFont(.sys12B)
    $0.theme.textColor = themed { $0.background }
  }

  // MARK: Initializing

  init(_ message: LocalizedString) {
    super.init(frame: .zero)
    self.theme.backgroundColor = themed { $0.primary }
    self.alpha = 1
    self.layer.cornerRadius = 8

    label.setText(message)
    self.addSubview(label)
    self.setupConstraints()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func didAddSubview(_ subview: UIView) {
    UIView.animate(withDuration: 3, delay: 1, options: .curveEaseOut, animations: { self.alpha = 0 }) { _ in self.removeFromSuperview()
    }
  }

  // MARK: Layout

  func setupConstraints() {
    guard let view = self.superview else { return }

    self.snp.makeConstraints {
      $0.height.equalTo(34)
      $0.leading.equalToSuperview().inset(8)
      $0.trailing.equalToSuperview().inset(8)
      $0.bottom.equalToSafeArea(view).inset(8)
    }
    label.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.leading.equalToSuperview().inset(12)
      $0.trailing.equalToSuperview().inset(12)
    }
  }
}
