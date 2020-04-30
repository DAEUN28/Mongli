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
import RxSwift

final class ReadDreamViewController: BaseViewController, View {

  typealias Reactor = ReadDreamViewReactor

  // MARK: UI

  private let dreamView = DreamView(.read)
  private let deleteButton = UIButton().then {
    $0.setTitle(.deleteDream)
    $0.titleLabel?.setFont(.hpi17L)
    $0.theme.titleColor(from: themed { $0.red }, for: .normal)
    $0.theme.backgroundColor = themed { $0.background }
    $0.layer.cornerRadius = 12
  }
  private let updateButton = UIButton().then {
    $0.setTitle(.updateDream)
    $0.titleLabel?.setFont(.hpi17L)
    $0.theme.titleColor(from: themed { $0.primary }, for: .normal)
    $0.theme.backgroundColor = themed { $0.background }
    $0.layer.cornerRadius = 12
  }

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
    subViews = [dreamView, deleteButton, updateButton]

    deleteButton.snp.makeConstraints {
      $0.height.equalTo(44)
      $0.bottom.equalToSafeArea(view).inset(12)
      $0.leading.equalToSuperview().inset(32)
      $0.trailing.equalTo(view.snp.centerX).offset(-6)
    }
    updateButton.snp.makeConstraints {
      $0.height.equalTo(44)
      $0.bottom.equalToSafeArea(view).inset(12)
      $0.leading.equalTo(view.snp.centerX).offset(6)
      $0.trailing.equalToSuperview().inset(32)
    }
    dreamView.snp.makeConstraints {
      $0.bottom.equalTo(deleteButton.snp.top).offset(-16)
    }
  }

  func setupDream(_ dream: Dream) {
    dreamView.dream.accept(dream)
  }

  // MARK: Binding

  func bind(reactor: Reactor) {
    bindAction(reactor)
    bindState(reactor)
  }
}

extension ReadDreamViewController {
  private func bindAction(_ reactor: Reactor) {
    dreamView.categoryButtonDidTap
      .map { Reactor.Action.categoryButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    deleteButton.rx.tap
      .map { Reactor.Action.deleteButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    updateButton.rx.tap
      .map { Reactor.Action.updateButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }

  private func bindState(_ reactor: Reactor) {
    reactor.state.map { $0.dream }
      .bind(to: dreamView.dream)
      .disposed(by: disposeBag)

    reactor.state.map { $0.dream?.date }
      .compactMap { $0 }
      .bind { [weak self] in self?.setupDreamNavigationBar($0) }
      .disposed(by: disposeBag)
  }
}
