//
//  CategoryInfoViewController.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/04/02.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift

class CategoryInfoViewController: UIViewController {

  // MARK: Properties

  private var didSetupConstraints = false
  private let disposeBag: DisposeBag = .init()

  // MARK: UI

  private let desciptionLabel = UILabel().then {
    $0.numberOfLines = 4
    $0.setText(.categoryInfoDesc)
    $0.setFont(.sys17S)
    $0.theme.textColor = themed { $0.assistant }

    $0.theme.textAttributes = themed { $0.categoryInfoDesc }
  }
  private let stackView = CategoryInfoViewController.makeStackView().then {
    $0.translatesAutoresizingMaskIntoConstraints = false
  }
  private let closeButton = BottomButton(.close)

  // MARK: View Life Cycle

  override func viewDidLoad() {
    view.theme.backgroundColor = themed { $0.background }

    view.addSubview(desciptionLabel)
    view.addSubview(stackView)
    view.addSubview(closeButton)

    closeButton.rx.tap.bind { [weak self] _ in
      self?.dismiss(animated: true, completion: nil)
    }
    .disposed(by: disposeBag)
  }

  // MARK: Layout

  override func updateViewConstraints() {
    if !didSetupConstraints {
      desciptionLabel.snp.makeConstraints {
        $0.top.equalToSuperview().inset(32)
        $0.leading.equalToSuperview().inset(32)
        $0.trailing.equalToSuperview().inset(32)
      }
      stackView.snp.makeConstraints {
        $0.top.equalTo(desciptionLabel.snp.bottom).offset(20)
        $0.leading.equalToSuperview().inset(32)
        $0.trailing.equalToSuperview().inset(32)
      }
      closeButton.snp.makeConstraints {
        $0.top.equalTo(stackView.snp.bottom).offset(32)
        $0.bottom.equalToSafeArea(view).inset(12)
        $0.leading.equalToSuperview().inset(32)
        $0.trailing.equalToSuperview().inset(32)
      }
      didSetupConstraints = true
    }
    super.updateViewConstraints()
  }

  private static func makeStackView() -> UIStackView {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.alignment = .fill
    stackView.distribution = .equalSpacing
    stackView.backgroundColor = .clear

    for category in Category.categories {
      let nameLabel = UILabel()
      nameLabel.setText(category.toName())
      nameLabel.setFont(.sys14B)
      nameLabel.textColor = category.toColor()

      let textLabel = UILabel()
      textLabel.setText(category.toText())
      textLabel.setFont(.sys10L)
      textLabel.theme.textColor = themed { $0.text }

      let containerView = UIStackView()
      containerView.axis = .vertical
      containerView.alignment = .fill
      containerView.distribution = .equalSpacing
      containerView.spacing = 8
      containerView.backgroundColor = .clear

      containerView.addArrangedSubview(nameLabel)
      containerView.addArrangedSubview(textLabel)
      stackView.addArrangedSubview(containerView)
    }

    return stackView
  }
}
