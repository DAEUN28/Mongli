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

  let buttonDidTap: BehaviorRelay<Void> = .init(value: ())

  private let disposeBag: DisposeBag = .init()
  private var didSetupConstraints = false

  // MARK: UI

  private let label = UILabel().then {
    $0.setFont(.sys14L)
    $0.theme.textColor = themed { $0.primary }
  }
  let button = UIButton().then {
    $0.layer.cornerRadius = 25
    $0.tintColor = .white
    $0.theme.backgroundColor = themed { $0.primary.withAlphaComponent(0.8) }
  }

  // MARK: Initializing

  init(_ symbolKey: SFSymbolKey) {
    super.init(frame: .zero)
    self.isHidden = true
    self.alpha = 0
    self.translatesAutoresizingMaskIntoConstraints = false

    button.setImage(UIImage(symbolKey), for: .normal)
    label.setText(LocalizedString(rawValue: String(describing: symbolKey))!)

    self.addSubview(button)
    self.addSubview(label)

    button.rx.tap.bind(to: buttonDidTap).disposed(by: self.disposeBag)
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Layout

  override func updateConstraints() {
    if !didSetupConstraints {
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
      self.snp.makeConstraints {
        $0.leading.equalTo(label)
      }
      didSetupConstraints = true
    }
    super.updateConstraints()
  }
}
