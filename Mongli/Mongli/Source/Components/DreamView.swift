//
//  DreamView.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/26.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import RxCocoa
import RxFlow
import RxSwift
import SnapKit

final class DreamView: UIView {

  enum `Type` {
    case create
    case read
    case update
  }

  // MARK: Properties

  let dream = BehaviorRelay<Dream?>(value: nil)
  let category = BehaviorRelay<Category>(value: .red)
  let title = BehaviorRelay<String>(value: "")
  let content = BehaviorRelay<String>(value: "")

  private let disposeBag = DisposeBag()
  private let keyboardSize = BehaviorRelay<CGRect>(value: .zero)
  private let buttons: [CategoryButton]
  private var translationYMultiflier: CGFloat = 1

  // MARK: UI

  private let categoryLabel = UILabel().then {
    $0.setText(.category)
    $0.font = FontManager.sys17SB
    $0.theme.textColor = themed { $0.darkWhite }
  }
  private let categoryInfoButton = UIButton().then {
    $0.setUnderlineTitle(.categoryInfoText)
    $0.titleLabel?.font = FontManager.sys12L
    $0.titleLabel?.theme.textColor = themed { $0.darkWhite }
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
    $0.translatesAutoresizingMaskIntoConstraints = false
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
    $0.returnKeyType = .done
    $0.enablesReturnKeyAutomatically = true
    $0.font = FontManager.sys17SB
    $0.theme.textColor = themed { $0.primary }
    $0.theme.backgroundColor = themed { $0.background }
    $0.layer.cornerRadius = 8
  }
  private let contentTextView = UITextView().then {
    $0.textAlignment = .natural
    $0.returnKeyType = .done
    $0.enablesReturnKeyAutomatically = true
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

  convenience init(_ type: Type, steps: PublishRelay<Step>) {
    self.init(frame: .zero)

    self.setupCategoryButton()
    self.setupTextFieldAndTextView()

    self.categoryInfoButton.rx.tap
      .map { MongliStep.categoryInfoIsRequired }
      .bind(to: steps)
      .disposed(by: self.disposeBag)

    switch type {
    case .create:
      return

    case .read:
      self.setupDream()
      for button in self.buttons {
        button.isEnabled = false
      }
      self.titleTextField.isEnabled = false
      self.contentTextView.isUserInteractionEnabled = false

    case .update:
      self.setupDream()
    }
  }

  override init(frame: CGRect) {
    self.buttons = [self.redButton,
                    self.orangeButton,
                    self.yellowButton,
                    self.greenButton,
                    self.tealButton,
                    self.blueButton,
                    self.indigoButton,
                    self.purpleButton]

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
      $0.top.equalToSafeArea(view).inset(20)
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
      $0.bottom.equalToSuperview()
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

// MARK: Setup

extension DreamView {
  private func setupCategoryButton() {
    for button in self.buttons {
      button.rx.tap.map { _ in button.category }
        .bind(to: self.category)
        .disposed(by: self.disposeBag)
    }

    self.category.distinctUntilChanged()
      .withPrevious()
      .bind { [weak self] old, new in
        guard let self = self else { return }
        self.buttons[new.rawValue].backgroundColor = new.toColor()
        self.buttons[new.rawValue].theme.titleColor(from: themed { $0.background }, for: .normal)
        if let old = old {
          self.buttons[old.rawValue].theme.backgroundColor = themed { $0.background }
          self.buttons[old.rawValue].titleLabel?.textColor = old.toColor()
        }
      }
      .disposed(by: self.disposeBag)
  }

  private func setupTextFieldAndTextView() {
    self.titleTextField.rx.text.orEmpty.distinctUntilChanged()
      .asDriver(onErrorJustReturn: "")
      .drive(self.title)
      .disposed(by: self.disposeBag)
    self.contentTextView.rx.text.orEmpty.distinctUntilChanged()
      .asDriver(onErrorJustReturn: "")
      .drive(self.content)
      .disposed(by: self.disposeBag)

    self.content.map { $0.isEmpty == false }
      .bind(to: self.contentTextViewPlaceholder.rx.isHidden)
      .disposed(by: self.disposeBag)

    self.titleTextField.rx.controlEvent(.editingDidEnd)
      .bind { [weak self] _ in
        self?.titleTextField.resignFirstResponder()
      }
      .disposed(by: self.disposeBag)

    self.contentTextView.rx.didEndEditing
      .bind { [weak self] _ in
        self?.contentTextView.resignFirstResponder()
        self?.transform = .identity
      }
      .disposed(by: self.disposeBag)
    NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
      .compactMap { ($0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue }
      .bind(to: self.keyboardSize)
      .disposed(by: self.disposeBag)
    self.contentTextView.rx.text.orEmpty
      .distinctUntilChanged()
      .filter { $0.last == "\n" }
      .withLatestFrom(self.keyboardSize)
      .filter { [weak self] in
        guard let self = self else { return false }
        return self.frame.maxY > $0.minY
      }
      .bind { [weak self] keyboardSize in
        guard let self = self else { return }
        let contentSizeMaxY
          = self.contentTextView.frame.minY + self.contentTextView.contentSize.height + self.frame.minY

        if contentSizeMaxY > keyboardSize.minY {
          UIView.animate(withDuration: 0.3) {
            self.transform = CGAffineTransform(translationX: 0, y: -12 * self.translationYMultiflier)
            self.translationYMultiflier += 1
          }
        }
      }
      .disposed(by: self.disposeBag)
    self.contentTextView.rx.didBeginEditing
      .withLatestFrom(self.keyboardSize)
      .bind { [weak self] keyboardSize in
        guard let self = self else { return }
        let contentSizeMaxY
          = self.contentTextView.frame.minY + self.contentTextView.contentSize.height + self.frame.minY

        if contentSizeMaxY > keyboardSize.minY {
          UIView.animate(withDuration: 0.3) {
            self.transform = CGAffineTransform(translationX: 0, y: -12 * self.translationYMultiflier)
          }
        }
      }
      .disposed(by: self.disposeBag)

    let toolBar = UIToolbar()
    toolBar.sizeToFit()
    let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let doneButton = UIBarButtonItem(title: LocalizedString.done.localized, style: .done, target: nil, action: nil)
    toolBar.setItems([flexibleSpace, doneButton], animated: false)
    toolBar.theme.tintColor = themed { $0.primary }
    self.contentTextView.inputAccessoryView = toolBar

    doneButton.rx.tap.bind { [weak self] _ in
      self?.contentTextView.resignFirstResponder()
    }
    .disposed(by: self.disposeBag)
  }

  private func setupDream() {
    self.dream.compactMap { $0 }
      .bind { [weak self] dream in
        if let category = Category(rawValue: dream.category) {
          self?.category.accept(category)
        }
        self?.titleTextField.text = dream.title
        self?.contentTextView.text = dream.content
      }
      .disposed(by: self.disposeBag)
  }
}
