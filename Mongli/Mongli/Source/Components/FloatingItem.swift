//
//  FloatingItem.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/04/15.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift

final class FloatingItem: UIView {

  // MARK: Properties

  let didButtonTap = BehaviorRelay<Void>(value: ())
  private let disposeBag = DisposeBag()

  // MARK: UI

  private let label = UILabel()
  private let button = UIButton()

  init(_ symbolKey: SFSymbolKey) {
    super.init(frame: .zero)
    self.isHidden = true
    self.alpha = 0
    self.translatesAutoresizingMaskIntoConstraints = false

    button.setImage(UIImage(symbolKey), for: .normal)
    button.frame.size = .init(width: 50, height: 50)
    button.layer.cornerRadius = 25
    button.tintColor = .white
    button.theme.backgroundColor = themed { $0.primary.withAlphaComponent(0.8) }

    label.setText(LocalizedString(rawValue: String(describing: symbolKey))!)
    label.font = FontManager.sys14L
    label.theme.textColor = themed { $0.primary }

    self.addSubview(button)
    self.addSubview(label)

    button.snp.makeConstraints {
      $0.width.equalTo(50)
      $0.height.equalTo(50)
      $0.top.equalToSuperview()
      $0.bottom.equalToSuperview()
      $0.trailing.equalToSuperview()
    }
    label.snp.makeConstraints {
      $0.centerY.equalTo(button.snp.centerY)
      $0.trailing.equalTo(button.snp.leading).offset(-12)
    }

    button.rx.tap.bind(to: didButtonTap).disposed(by: self.disposeBag)
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
