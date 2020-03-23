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
    $0.font = FontManager.hpi12L
    $0.textColor = themeService.attrs.logoText
  }

  // MARK: Initializing

  init(_ message: LocalizedString) {
    super.init(frame: .zero)
    self.theme.backgroundColor = themed { $0.primary }
    self.alpha = 1
    self.label.set(text: message)

    let layer = CAShapeLayer()

    layer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 8).cgPath

    layer.shadowColor = UIColor.black.cgColor
    layer.shadowPath = layer.path
    layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
    layer.shadowOpacity = 0.2
    layer.shadowRadius = 3

    self.layer.addSublayer(layer)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func didAddSubview(_ subview: UIView) {
    UIView.animate(withDuration: 4, delay: 1, options: .curveEaseOut, animations: { self.alpha = 0 }) { _ in
      self.removeFromSuperview()
    }
  }

  // MARK: Layout

  override func layoutSubviews() {
    self.label.sizeToFit()

    self.snp.makeConstraints {
      $0.height.equalTo(34)
      $0.leading.equalToSuperview().inset(8)
      $0.trailing.equalToSuperview().inset(8)
      $0.bottom.equalToSuperview()
    }

    self.label.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.leading.equalToSuperview().inset(12)
      $0.trailing.equalToSuperview().inset(12)
    }
  }
}
