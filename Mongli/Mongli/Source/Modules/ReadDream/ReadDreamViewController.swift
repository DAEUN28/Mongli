//
//  ReadDreamViewController.swift
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

final class ReadDreamViewController: BaseViewController, View, Stepper {

  typealias Reactor = ReadDreamViewReactor

  // MARK: Properties

  var steps = PublishRelay<Step>()

  // MARK: UI

  private let dreamView = DreamView(.read)
  private let deleteButton = UIButton().then {
    $0.setTitle(.deleteDreamText)
    $0.titleLabel?.font = FontManager.hpi17L
    $0.titleLabel?.theme.textColor = themed { $0.red }
    $0.theme.backgroundColor = themed { $0.background }
    $0.layer.cornerRadius = 12
  }
  private let updateButton = UIButton().then {
    $0.setTitle(.updateDreamText)
    $0.titleLabel?.font = FontManager.hpi17L
    $0.titleLabel?.theme.textColor = themed { $0.primary }
    $0.theme.backgroundColor = themed { $0.background }
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
    self.subViews = [self.dreamView, self.deleteButton, self.updateButton, self.spinner]
  }

  // MARK: Setup

  override func setupConstraints() {
    self.deleteButton.snp.makeConstraints {
      $0.height.equalTo(44)
      $0.bottom.equalToSafeArea(self.view).inset(12)
      $0.leading.equalToSuperview().inset(32)
      $0.trailing.equalTo(self.view.snp.centerX).offset(6)
    }
    self.updateButton.snp.makeConstraints {
      $0.height.equalTo(44)
      $0.bottom.equalToSafeArea(self.view).inset(12)
      $0.leading.equalTo(self.view.snp.centerX).inset(6)
      $0.trailing.equalToSuperview().inset(32)
    }
    self.dreamView.snp.makeConstraints {
      $0.bottom.equalTo(self.deleteButton.snp.top).offset(-16)
    }
  }

  override func setupUserInteraction() {

  }

  // MARK: Binding

  func bind(reactor: Reactor) {
    self.bindAction(reactor)
    self.bindState(reactor)
  }
}

extension ReadDreamViewController {
  private func bindAction(_ reactor: Reactor) {
    self.deleteButton.rx.tap
      .map { Reactor.Action.deleteDream }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
  }

  private func bindState(_ reactor: Reactor) {
    reactor.state.map { $0.dream }.debug()
      .asDriver(onErrorJustReturn: nil)
      .drive(self.dreamView.dream)
      .disposed(by: self.disposeBag)
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
