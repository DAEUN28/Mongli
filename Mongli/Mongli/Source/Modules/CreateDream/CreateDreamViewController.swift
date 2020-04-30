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
import RxSwift

final class CreateDreamViewController: BaseViewController, View {

  typealias Reactor = CreateDreamViewReactor

  // MARK: Properties

  private let date: BehaviorRelay<Date> = .init(value: .init())

  // MARK: UI

  private let dreamView: DreamView = .init(.create)
  private let doneButton: UIButton = UIButton().then {
    $0.setTitle(.createDream)
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

  // MARK: View Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    self.subViews = [dreamView, doneButton, spinner]

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

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.view.endEditing(true)
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
    BehaviorRelay.combineLatest(dreamView.title, dreamView.content) { !$0.isEmpty && !$1.isEmpty }
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

extension CreateDreamViewController {
  private func bindAction(_ reactor: Reactor) {
    let dream = Observable.combineLatest(date.map { dateFormatter.string(from: $0) }.asObservable(),
                                         dreamView.category.asObservable(),
                                         dreamView.title.asObservable(),
                                         dreamView.content.asObservable()) { Dream(id: nil,
                                                                                   date: $0,
                                                                                   category: $1.rawValue,
                                                                                   title: $2,
                                                                                   content: $3) }
    doneButton.rx.tap.withLatestFrom(dream)
      .map { Reactor.Action.createDream($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    setupDreamNavigationBar().rx.tap
      .map { Reactor.Action.dateTapped }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    dreamView.categoryButtonTapped
      .map { Reactor.Action.categoryInfoTapped }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }

  private func bindState(_ reactor: Reactor) {
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
