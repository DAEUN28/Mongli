//
//  CreateDreamViewController.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/20.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxFlow
import RxSwift

final class CreateDreamViewController: BaseViewController, View, Stepper {

  typealias Reactor = CreateDreamViewReactor

  // MARK: Properties

  var steps = PublishRelay<Step>()

  private let date = BehaviorRelay<Date>(value: Date())

  // MARK: UI

  private let dreamView = DreamView(.create)
  private let doneButton = UIButton().then {
    $0.setTitle(.createDream)
    $0.titleLabel?.font = FontManager.hpi17L
    $0.layer.cornerRadius = 12
  }
  private let spinner = Spinner()

  // MARK: initializing

  init(_ reactor: Reactor) {
    defer { self.reactor = reactor }
    super.init()
  }

  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: View Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    self.subViews = [self.dreamView, self.doneButton, self.spinner]
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.view.endEditing(true)
  }

  // MARK: Setup

  override func setupConstraints() {
    self.doneButton.snp.makeConstraints {
      $0.height.equalTo(44)
      $0.bottom.equalToSafeArea(self.view).inset(12)
      $0.leading.equalToSuperview().inset(32)
      $0.trailing.equalToSuperview().inset(32)
    }
    self.dreamView.snp.makeConstraints {
      $0.bottom.equalTo(self.doneButton.snp.top).offset(-16)
    }
  }

  override func setupUserInteraction() {
    BehaviorRelay.combineLatest(self.dreamView.title, self.dreamView.content) { !($0.isEmpty && $1.isEmpty) }
      .do(onNext: { [weak self] in self?.setDoneButtonTheme($0) })
      .bind(to: self.doneButton.rx.isEnabled)
      .disposed(by: self.disposeBag)
    self.setupDreamNavigationBar(date: date.asDriver()).rx.tap
      .map { _ in MongliStep.datePickerActionSheet { [weak self] in self?.date.accept($0) } }
      .bind(to: self.steps)
      .disposed(by: self.disposeBag)
  }

  // MARK: Binding

  func bind(reactor: Reactor) {
    self.bindAction(reactor)
    self.bindState(reactor)
  }
}

extension CreateDreamViewController {
  private func bindAction(_ reactor: Reactor) {
    let dream = Observable.combineLatest(self.date.map { dateFormatter.string(from: $0) }.asObservable(),
                                         self.dreamView.category.asObservable(),
                                         self.dreamView.title.asObservable(),
                                         self.dreamView.content.asObservable()) {  Dream(id: nil,
                                                                                         date: $0,
                                                                                         category: $1.rawValue,
                                                                                         title: $2,
                                                                                         content: $3) }
    self.doneButton.rx.tap.withLatestFrom(dream)
      .map { Reactor.Action.createDream($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
  }

  private func bindState(_ reactor: Reactor) {
    reactor.state.map { $0.error }
      .compactMap { $0 }
      .map { MongliStep.toast($0) }
      .bind(to: self.steps)
      .disposed(by: self.disposeBag)
    reactor.state.map { $0.isLoading }.skip(1)
      .filter { !$0 }
      .map { _ in MongliStep.dismiss }
      .bind(to: self.steps)
      .disposed(by: self.disposeBag)
    reactor.state.map { $0.isLoading }
      .bind(to: self.spinner.rx.isAnimating)
      .disposed(by: self.disposeBag)
  }
}

// MARK: Util

extension CreateDreamViewController {
  private func setDoneButtonTheme(_ isEnabled: Bool) {
    if isEnabled {
      self.doneButton.theme.backgroundColor = themed { $0.buttonEnable }
      self.doneButton.theme.titleColor(from: themed { $0.buttonEnableTitle }, for: .normal)
    } else {
      self.doneButton.theme.backgroundColor = themed { $0.buttonDisable }
      self.doneButton.theme.titleColor(from: themed { $0.buttonDisableTitle }, for: .normal)
    }
  }
}
