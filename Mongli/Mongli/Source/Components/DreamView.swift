//
//  DreamView.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/26.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

final class DreamView: UIView {

  // MARK: Properties

  let category = BehaviorRelay<Category>(value: .red)
  let title: Observable<String?>
  let content: Observable<String?>

  private let disposeBag = DisposeBag()

  // MARK: UI

  private let categoryLabel = UILabel().then {
    $0.setText(.category)
    $0.font = FontManager.sys17SB
    $0.theme.textColor = themed { $0.darkWhite }
  }
  let categoryInfoButton = UIButton().then {
    $0.setUnderlineTitle(.categoryInfoText)
    $0.titleLabel?.font = FontManager.sys12L
    $0.theme.tintColor = themed { $0.darkWhite }
  }
  private let subStackView1 = UIStackView().then {
    $0.axis = .horizontal
    $0.alignment = .fill
    $0.distribution = .fillEqually
    $0.spacing = 20
  }
  private let subStackView2 = UIStackView().then {
    $0.axis = .horizontal
    $0.alignment = .fill
    $0.distribution = .fillEqually
    $0.spacing = 20
  }
  private let stackView = UIStackView().then {
    $0.axis = .vertical
    $0.alignment = .fill
    $0.distribution = .fillEqually
    $0.spacing = 16
  }
  private let redButton = CategoryButton(.red)
  private let orangeButton = CategoryButton(.orange)
  private let yellowButton = CategoryButton(.yellow)
  private let greenButton = CategoryButton(.green)
  private let tealButton = CategoryButton(.teal)
  private let blueButton = CategoryButton(.blue)
  private let indigoButton = CategoryButton(.indigo)
  private let purpleButton = CategoryButton(.purple)
  private let titleTextField = UITextField().then {
    $0.placeholder = LocalizedString.dreamTitlePlaceholder.localized
    $0.textAlignment = .center
    $0.font = FontManager.sys17SB
    $0.theme.textColor = themed { $0.primary }
    $0.theme.backgroundColor = themed { $0.background }
    $0.layer.cornerRadius = 8
  }
  private let contentTextView = UITextView().then {
    $0.textAlignment = .natural
    $0.font = FontManager.sys10L
    $0.theme.textColor = themed { $0.text }
    $0.theme.backgroundColor = themed { $0.background }
    $0.layer.cornerRadius = 12
    $0.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
  }
  private let contentTextViewPlaceholder = UILabel().then {
    $0.text = LocalizedString.dreamContentPlaceholder.localized
    $0.textAlignment = .natural
    $0.font = FontManager.sys10L
    $0.theme.textColor = themed { $0.placeholder }
  }

  // MARK: Initializing

  override init(frame: CGRect) {
    self.title = self.titleTextField.rx.text.distinctUntilChanged()
    self.content = self.contentTextView.rx.text.distinctUntilChanged()

    super.init(frame: frame)

    self.subStackView1.addArrangedSubview(self.redButton)
    self.subStackView1.addArrangedSubview(self.orangeButton)
    self.subStackView1.addArrangedSubview(self.yellowButton)
    self.subStackView1.addArrangedSubview(self.greenButton)
    self.subStackView2.addArrangedSubview(self.tealButton)
    self.subStackView2.addArrangedSubview(self.blueButton)
    self.subStackView2.addArrangedSubview(self.indigoButton)
    self.subStackView2.addArrangedSubview(self.purpleButton)
    self.stackView.addArrangedSubview(self.subStackView1)
    self.stackView.addArrangedSubview(self.subStackView2)

    self.addSubview(self.categoryLabel)
    self.addSubview(self.categoryInfoButton)
    self.addSubview(self.stackView)
    self.addSubview(self.titleTextField)
    self.addSubview(self.contentTextView)
    self.addSubview(self.contentTextViewPlaceholder)

    self.setupCategoryButton()

    self.content.map { $0 != nil }
      .bind(to: self.contentTextViewPlaceholder.rx.isHidden)
      .disposed(by: self.disposeBag)
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Layout

  override func layoutSubviews() {
    guard let view = self.superview else { return }

    self.categoryLabel.sizeToFit()
    self.categoryInfoButton.sizeToFit()
    self.contentTextViewPlaceholder.sizeToFit()

    self.snp.makeConstraints {
      $0.top.equalToSafeArea(view).inset(28)
      $0.leading.equalToSuperview().inset(32)
      $0.trailing.equalToSuperview().inset(32)
    }
    self.categoryLabel.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.leading.equalToSuperview().inset(12)
    }
    self.categoryInfoButton.snp.makeConstraints {
      $0.bottomMargin.equalTo(self.categoryLabel.snp.bottom)
      $0.leading.equalTo(self.categoryLabel.snp.trailing).offset(4)
    }
    self.stackView.snp.makeConstraints {
      $0.top.equalTo(self.categoryLabel.snp.bottom).offset(20)
      $0.leading.equalToSuperview().inset(6)
      $0.trailing.equalToSuperview().inset(6)
    }
    self.titleTextField.snp.makeConstraints {
      $0.height.equalTo(28)
      $0.top.equalTo(self.stackView.snp.bottom).offset(24)
      $0.leading.equalToSuperview()
      $0.trailing.equalToSuperview()
    }
    self.contentTextView.snp.makeConstraints {
      $0.top.equalTo(self.titleTextField.snp.bottom).offset(10)
      $0.leading.equalToSuperview()
      $0.trailing.equalToSuperview()
    }
    self.contentTextViewPlaceholder.snp.makeConstraints {
      $0.top.equalTo(self.contentTextView.snp.top).inset(12)
      $0.leading.equalTo(self.contentTextView.snp.leading).inset(12)
      $0.trailing.equalTo(self.contentTextView.snp.trailing).inset(12)
    }
  }
}

extension DreamView {
  private func setupCategoryButton() {
    let buttons = [self.redButton,
                   self.orangeButton,
                   self.yellowButton,
                   self.greenButton,
                   self.tealButton,
                   self.blueButton,
                   self.indigoButton,
                   self.purpleButton]

    for button in buttons {
      button.rx.tap.map { _ in button.category }
        .bind(to: self.category)
        .disposed(by: self.disposeBag)
    }

    self.category.distinctUntilChanged()
      .withPrevious()
      .subscribe(onNext: { old, new in
        guard let old = old else { return }
        buttons[old.rawValue].theme.backgroundColor = themed { $0.background }
        buttons[old.rawValue].tintColor = old.toColor()
        buttons[new.rawValue].backgroundColor = new.toColor()
        buttons[new.rawValue].theme.tintColor = themed { $0.background }
      })
      .disposed(by: self.disposeBag)
  }
}
