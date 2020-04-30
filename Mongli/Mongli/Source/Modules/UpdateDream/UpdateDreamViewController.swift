//
//  UpdateDreamViewController.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/04/02.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxFlow
import RxSwift

final class UpdateDreamViewController: BaseViewController, View, Stepper {

  typealias Reactor = UpdateDreamViewReactor

  // MARK: Properties

  var steps = PublishRelay<Step>()

  private let date = BehaviorRelay<Date>(value: Date())

  // MARK: UI

  private let dreamView = DreamView(.update)
  private let doneButton = UIButton().then {
    $0.setTitle(.updateDream)
    $0.titleLabel?.setFont(.hpi17L)
    $0.layer.cornerRadius = 12
  }
  private let spinner = Spinner()

  // MARK: Initializing

  init(_ reactor: Reactor) {
    defer { self.reactor = reactor }
    super.init()
  }

  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Setup

  override func setupConstraints() {
    self.subViews = [self.dreamView, self.doneButton, self.spinner]

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
    BehaviorRelay.combineLatest(self.dreamView.title, self.dreamView.content) { !$0.isEmpty && !$1.isEmpty }
      .do(onNext: { [weak self] in self?.doneButton.setTheme($0) })
      .bind(to: self.doneButton.rx.isEnabled)
      .disposed(by: self.disposeBag)

    self.addCalendarBarButton().rx.tap
      .map { _ in MongliStep.datePickerActionSheet { [weak self] in self?.date.accept($0) } }
      .bind(to: self.steps)
      .disposed(by: self.disposeBag)

    dreamView.categoryButtonTapped
      .map { MongliStep.categoryInfoIsRequired }
      .bind(to: steps)
      .disposed(by: disposeBag)

    // present alert when willMove
    //    let id = reactor?.initialState.existingDream.id
    //    let dream = Observable.combineLatest(self.date.map { dateFormatter.string(from: $0) }.asObservable(),
    //                                         self.dreamView.category.asObservable(),
    //                                         self.dreamView.title.asObservable(),
    //                                         self.dreamView.content.asObservable()) { Dream(id: id,
    //                                                                                         date: $0,
    //                                                                                         category: $1.rawValue,
    //                                                                                         title: $2,
    //                                                                                         content: $3) }
    //
    //    guard let touchesMoved = self.navigationController?.interactivePopGestureRecognizer?.rx.touchesMoved else { return }
    //    let backButton = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
    //    self.navigationItem.backBarButtonItem = backButton
    //
    //    Observable.combineLatest(touchesMoved, backButton.rx.tap.asObservable())
    //      .withLatestFrom(dream)
    //      .filter { [weak self] in self?.reactor?.initialState.existingDream != $0 }
    //      .map { _ in MongliStep.alert(.cancelWrite) { [weak self] _ in self?.steps.accept(MongliStep.dismiss) } }
    //      .bind(to: self.steps)
    //      .disposed(by: self.disposeBag)
  }

  // MARK: Binding

  func bind(reactor: Reactor) {
    self.bindAction(reactor)
    self.bindState(reactor)
  }
}

extension UpdateDreamViewController {
  private func bindAction(_ reactor: Reactor) {
    let id = reactor.initialState.existingDream.id
    let dream = Observable.combineLatest(self.date.map { dateFormatter.string(from: $0) }.asObservable(),
                                         self.dreamView.category.asObservable(),
                                         self.dreamView.title.asObservable(),
                                         self.dreamView.content.asObservable()) { Dream(id: id,
                                                                                         date: $0,
                                                                                         category: $1.rawValue,
                                                                                         title: $2,
                                                                                         content: $3) }
    self.doneButton.rx.tap.withLatestFrom(dream)
      .map { Reactor.Action.updateDream($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
  }

  private func bindState(_ reactor: Reactor) {
    reactor.state.map { $0.existingDream }
      .take(1)
      .bind(to: self.dreamView.dream)
      .disposed(by: self.disposeBag)
    reactor.state.map { $0.isLoading }
      .distinctUntilChanged()
      .bind(to: self.spinner.rx.isAnimating)
      .disposed(by: self.disposeBag)
  }
}
