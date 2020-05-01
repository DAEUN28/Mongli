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
import RxSwift

final class UpdateDreamViewController: BaseViewController, View {

  typealias Reactor = UpdateDreamViewReactor

  // MARK: Properties

  private let backAction: PublishRelay<Void> = .init()

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
    super.init()
    self.reactor = reactor
    self.subViews = [dreamView, doneButton, spinner]
    self.setupUserInteraction()
  }

  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: View Life Cycle

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.setupDreamNavigationBar()

    self.navigationController?.interactivePopGestureRecognizer?.rx.touchesMoved
      .bind(to: backAction)
      .disposed(by: disposeBag)

    self.navigationItem.leftBarButtonItem?.rx.tap
      .bind(to: backAction)
      .disposed(by: disposeBag)
  }

  // MARK: Setup

  override func setupConstraints() {
    doneButton.snp.makeConstraints {
      $0.height.equalTo(44)
      $0.bottom.equalToSafeArea(view).inset(12)
      $0.leading.equalToSuperview().inset(32)
      $0.trailing.equalToSuperview().inset(32)
    }
    dreamView.snp.makeConstraints {
      $0.bottom.equalTo(doneButton.snp.top).offset(-16)
    }
  }

  override func setupUserInteraction() {
    dreamView.contentsAreExist
      .distinctUntilChanged()
      .do(onNext: { [weak self] in self?.doneButton.setTheme($0) })
      .bind(to: doneButton.rx.isEnabled)
      .disposed(by: disposeBag)
  }

  // MARK: Binding

  func bind(reactor: Reactor) {
    bindAction(reactor)
    bindState(reactor)
  }
}

extension UpdateDreamViewController {
  private func bindAction(_ reactor: Reactor) {
    let dream: Observable<Dream> = dreamView.dream.map { [weak reactor] in
      guard let reactor = reactor else { return .init() }
      return $0.newDream(date: dateFormatter.string(from: reactor.currentState.date))
    }

    doneButton.rx.tap.withLatestFrom(dream)
      .map { Reactor.Action.updateDream($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    addCalendarBarButton().rx.tap
      .map { Reactor.Action.dateButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    dreamView.categoryButtonDidTap
      .map { Reactor.Action.categoryInfoButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    backAction.withLatestFrom(dreamView.contentsAreExist)
      .filter { $0 }
      .map { _ in Reactor.Action.cancelWrite }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }

  private func bindState(_ reactor: Reactor) {
    reactor.state.map { $0.existingDream }
      .distinctUntilChanged()
      .bind(to: dreamView.existingDream)
      .disposed(by: disposeBag)

    reactor.state.map { $0.date }
      .compactMap { [weak self] in self?.dreamView.dream.value.newDream(date: dateFormatter.string(from: $0)) }
      .distinctUntilChanged()
      .bind(to: dreamView.dream)
      .disposed(by: disposeBag)

    reactor.state.map { $0.date }
      .distinctUntilChanged()
      .map { LocalizedString.dateFormat.localizedDate($0, .dreamAdverb) }
      .bind(to: self.rx.title)
      .disposed(by: disposeBag)

    reactor.state.map { $0.isLoading }
      .distinctUntilChanged()
      .bind(to: spinner.rx.isAnimating)
      .disposed(by: disposeBag)
  }
}
