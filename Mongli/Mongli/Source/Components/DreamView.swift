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

  let dream: BehaviorRelay<Dream> = .init(value: .init())
  let existingDream: BehaviorRelay<Dream?> = .init(value: nil)
  let categoryButtonDidTap: BehaviorRelay<Void> = .init(value: ())
  let contentsAreExist: BehaviorRelay<Bool> = .init(value: false)
  let titleCountIsOver: BehaviorRelay<Bool> = .init(value: false)

  private let disposeBag: DisposeBag = .init()
  private let category: BehaviorRelay<Category> = .init(value: .red)
  private let keyboardSize: BehaviorRelay<CGRect> = .init(value: .zero)
  private var translationYMultiflier: CGFloat = 1
  private var didSetupConstraints = false

  // MARK: UI

  private let categoryLabel = UILabel().then {
    $0.setText(.category)
    $0.setFont(.sys17S)
    $0.theme.textColor = themed { $0.darkWhite }
  }
  private let categoryInfoButton = UIButton().then {
    $0.setUnderlineTitle(.categoryInfoText)
    $0.titleLabel?.setFont(.sys12L)
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
  private let buttons: [CategoryButton] = [.init(.red), .init(.orange), .init(.yellow), .init(.green),
                                           .init(.teal), .init(.blue), .init(.indigo), .init(.purple)]
  private let titleTextField = UITextField().then {
    $0.placeholder = LocalizedString.dreamTitlePlaceholder.localized
    $0.textAlignment = .center
    $0.returnKeyType = .done
    $0.enablesReturnKeyAutomatically = true
    $0.font = Font.sys17S.uifont
    $0.theme.textColor = themed { $0.primary }
    $0.theme.backgroundColor = themed { $0.background }
    $0.layer.cornerRadius = 8
  }
  private let contentTextView = UITextView().then {
    $0.textAlignment = .natural
    $0.returnKeyType = .next
    $0.font = Font.sys10L.uifont
    $0.theme.textColor = themed { $0.text }
    $0.theme.backgroundColor = themed { $0.background }
    $0.layer.cornerRadius = 12
    $0.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
  }
  private let contentTextViewPlaceholder = UILabel().then {
    $0.text = LocalizedString.dreamContentPlaceholder.localized
    $0.textAlignment = .natural
    $0.setFont(.sys10L)
    $0.theme.textColor = themed { $0.placeholder }
  }
  private let toolBar = UIToolbar().then {
    $0.sizeToFit()
    let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let doneButton = UIBarButtonItem(title: LocalizedString.done.localized, style: .done, target: nil, action: nil)
    $0.setItems([flexibleSpace, doneButton], animated: false)
    $0.theme.tintColor = themed { $0.primary }
  }

  // MARK: Initializing

  // swiftlint:disable function_body_length
  convenience init(_ type: Type) {
    self.init(frame: .zero)

    let title: BehaviorRelay<String> = .init(value: "")
    let content = contentTextView.rx.text.orEmpty.distinctUntilChanged()
    titleTextField.rx.text.orEmpty.distinctUntilChanged()
      .bind(to: title)
      .disposed(by: disposeBag)

    Observable<Dream>.combineLatest(category.asObservable(), title, content) { [weak self] in
      guard let self = self else { return .init() }
      if let dream = self.existingDream.value { return dream.newDream(category: $0.rawValue, title: $1, content: $2) }
      return self.dream.value.newDream(category: $0.rawValue, title: $1, content: $2)
    }
    .bind(to: dream)
    .disposed(by: disposeBag)

    categoryInfoButton.rx.tap
      .bind(to: categoryButtonDidTap)
      .disposed(by: disposeBag)

    setupCategoryButton()
    setupTextField()
    setupTextView()

    switch type {
    case .create:
      dream.map { !$0.title.isEmpty && !$0.content.isEmpty }
        .distinctUntilChanged()
        .bind(to: contentsAreExist)
        .disposed(by: disposeBag)

      return

    case .read:
      setupDream()
      for button in buttons {
        button.isEnabled = false
      }
      titleTextField.isEnabled = false
      contentTextView.isUserInteractionEnabled = false

    case .update:
      setupDream()

      titleTextField.rx.observe(String.self, "text")
        .compactMap { $0 }
        .bind(to: title)
        .disposed(by: disposeBag)

      dream.map { [weak self] in
        !$0.title.isEmpty && !$0.content.isEmpty && $0 != self?.existingDream.value
      }
      .distinctUntilChanged()
      .bind(to: contentsAreExist)
      .disposed(by: disposeBag)
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    for button in buttons {
      switch button.category {
      case .red, .orange, .yellow, .green: subStackView1.addArrangedSubview(button)
      default: subStackView2.addArrangedSubview(button)
      }
    }
    stackView.addArrangedSubview(subStackView1)
    stackView.addArrangedSubview(subStackView2)

    addSubview(categoryLabel)
    addSubview(categoryInfoButton)
    addSubview(stackView)
    addSubview(titleTextField)
    addSubview(contentTextView)
    addSubview(contentTextViewPlaceholder)
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Layout

  override func updateConstraints() {
    if !didSetupConstraints {
      self.setupConstraints()
      didSetupConstraints = true
    }
    super.updateConstraints()
  }

  private func setupConstraints() {
    guard let view = superview else { return }

    snp.makeConstraints {
      $0.top.equalToSafeArea(view).inset(12)
      $0.leading.equalToSuperview().inset(32)
      $0.trailing.equalToSuperview().inset(32)
    }
    categoryLabel.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.leading.equalToSuperview().inset(12)
    }
    categoryInfoButton.snp.makeConstraints {
      $0.bottomMargin.equalTo(categoryLabel.snp.bottom)
      $0.leading.equalTo(categoryLabel.snp.trailing).offset(4)
    }
    stackView.snp.makeConstraints {
      $0.top.equalTo(categoryLabel.snp.bottom).offset(20)
      $0.leading.equalToSuperview().inset(6)
      $0.trailing.equalToSuperview().inset(6)
    }
    titleTextField.snp.makeConstraints {
      $0.height.equalTo(28)
      $0.top.equalTo(stackView.snp.bottom).offset(24)
      $0.leading.equalToSuperview()
      $0.trailing.equalToSuperview()
    }
    contentTextView.snp.makeConstraints {
      $0.top.equalTo(titleTextField.snp.bottom).offset(10)
      $0.bottom.equalToSuperview()
      $0.leading.equalToSuperview()
      $0.trailing.equalToSuperview()
    }
    contentTextViewPlaceholder.snp.makeConstraints {
      $0.top.equalTo(contentTextView.snp.top).inset(12)
      $0.leading.equalTo(contentTextView.snp.leading).inset(12)
      $0.trailing.equalTo(contentTextView.snp.trailing).inset(12)
    }
  }
}

// MARK: Setup

extension DreamView {
  private func setupCategoryButton() {
    for button in buttons {
      button.rx.tap.map { _ in button.category }
        .bind(to: category)
        .disposed(by: disposeBag)
    }

    category.distinctUntilChanged()
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
    .disposed(by: disposeBag)
  }

  private func setupTextField() {
    titleTextField.rx.controlEvent(.editingDidEnd)
      .bind { [weak self] _ in
        self?.titleTextField.resignFirstResponder()
    }
    .disposed(by: disposeBag)

    titleTextField.rx.text.orEmpty
      .map { $0.count > 19 }
      .do(afterNext: { [weak self] in
        if $0 { self?.titleTextField.text?.removeLast(1) }
      })
      .bind(to: titleCountIsOver)
      .disposed(by: disposeBag)
  }

  private func setupTextView() {
    contentTextView.rx.text.orEmpty.distinctUntilChanged()
      .map { $0.isEmpty == false }
      .bind(to: contentTextViewPlaceholder.rx.isHidden)
      .disposed(by: disposeBag)

    contentTextView.rx.didEndEditing
      .bind { [weak self] _ in
        self?.contentTextView.resignFirstResponder()
        self?.transform = .identity
      }
      .disposed(by: disposeBag)

    NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
      .compactMap { ($0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue }
      .bind(to: keyboardSize)
      .disposed(by: disposeBag)

    contentTextView.rx.text.orEmpty
      .distinctUntilChanged()
      .filter { $0.last == "\n" }
      .withLatestFrom(keyboardSize)
      .filter { [weak self] in
        guard let self = self else { return false }
        return self.frame.maxY > $0.minY
      }
      .bind { [weak self] keyboardSize in
        guard let self = self else { return }
        let contentSizeMaxY = self.contentTextView.frame.minY
          + self.contentTextView.contentSize.height
          + self.frame.minY

        if contentSizeMaxY > keyboardSize.minY {
          UIView.animate(withDuration: 0.3) {
            self.transform = CGAffineTransform(translationX: 0, y: -12 * self.translationYMultiflier)
            self.translationYMultiflier += 1
          }
        }
      }
      .disposed(by: disposeBag)

    contentTextView.rx.didBeginEditing
      .withLatestFrom(keyboardSize)
      .bind { [weak self] keyboardSize in
        guard let self = self else { return }
        let contentSizeMaxY = self.contentTextView.frame.minY
          + self.contentTextView.contentSize.height
          + self.frame.minY

        if contentSizeMaxY > keyboardSize.minY {
          UIView.animate(withDuration: 0.3) {
            self.transform = CGAffineTransform(translationX: 0, y: -12 * self.translationYMultiflier)
          }
        }
      }
      .disposed(by: disposeBag)

    let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
    let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let doneButton = UIBarButtonItem(title: LocalizedString.done.localized, style: .done, target: nil, action: nil)
    toolBar.setItems([flexibleSpace, doneButton], animated: false)
    toolBar.theme.tintColor = themed { $0.primary }
    contentTextView.inputAccessoryView = toolBar

    doneButton.rx.tap
      .bind { [weak self] _ in self?.contentTextView.resignFirstResponder() }
      .disposed(by: disposeBag)
  }

  private func setupDream() {
    existingDream.compactMap { $0 }
      .bind { [weak self] dream in
        if let category = Category(rawValue: dream.category) {
          self?.category.accept(category)
        }
        self?.titleTextField.text = dream.title
        self?.contentTextView.text = dream.content
    }
    .disposed(by: disposeBag)
  }
}
