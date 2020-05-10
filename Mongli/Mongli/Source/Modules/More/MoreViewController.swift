//
//  MoreViewController.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/20.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

class MoreViewController: BaseViewController, View {

  typealias Reactor = MoreViewReactor

  // MARK: Properties

  private var isMenuOpend = false

  // MARK: UI

  private let titleLabel = UILabel().then {
    let title = (StorageManager.shared.readUser()?.name ?? "몽리")
      + String(format: LocalizedString.moreText.localized, 0)
    $0.numberOfLines = 2
    let attributedString = NSMutableAttributedString(string: title)
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = 4
    attributedString.addAttribute(.paragraphStyle,
                                  value: paragraphStyle,
                                  range: .init(location: 0, length: attributedString.length))
    $0.attributedText = attributedString
    $0.setFont(.hpi20L)
    $0.theme.textColor = themed { $0.darkWhite }
  }
  private let coverView = CoverView().then {
    $0.label.isHidden = true
    $0.button.setUnderlineTitle(.categoryInfoText)
  }
  private let chartView = ChartView()
  private let menuButton = UIButton(frame: .init(origin: .zero, size: .init(width: 50, height: 50))).then {
    $0.setImage(UIImage(.menu), for: .normal)
    $0.layer.cornerRadius = 25
    $0.tintColor = .white
    $0.theme.backgroundColor = themed { $0.primary }
  }
  private let floatingItems: [FloatingItem] = [.init(.accountManagement), .init(.opensourceLisence), .init(.contact)]
  private let placeholderView = PlaceholderView(.noContent)

  // MARK: Initializing

  init(_ reactor: Reactor) {
    super.init()
    self.reactor = reactor
    self.subViews = [titleLabel, coverView, chartView, menuButton,
                     floatingItems[0], floatingItems[1], floatingItems[2], placeholderView]
    self.setupUserInteraction()
  }

  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: View Life Cycle

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    AnalyticsManager.view_more.log(self.classForCoder.description())
  }

  // MARK: Setup

  override func setupConstraints() {
    titleLabel.snp.makeConstraints {
      $0.height.equalTo(titleLabel.intrinsicContentSize.height)
      $0.top.equalToSafeArea(view).inset(20)
      $0.leading.equalToSuperview().inset(28)
    }
    coverView.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(20)
      $0.bottom.equalToSafeArea(view)
      $0.leading.equalToSuperview()
      $0.trailing.equalToSuperview()
    }
    coverView.button.snp.makeConstraints {
      $0.top.equalToSuperview().inset(40)
    }
    chartView.snp.makeConstraints {
      $0.top.equalTo(coverView.button.snp.bottom).offset(8)
      $0.bottom.equalToSafeArea(view).inset(80)
      $0.leading.equalToSuperview().inset(28)
      $0.trailing.equalToSuperview().inset(28)
    }
    menuButton.snp.makeConstraints {
      $0.width.equalTo(50)
      $0.height.equalTo(50)
      $0.bottom.equalToSafeArea(view).inset(12)
      $0.trailing.equalToSafeArea(view).inset(12)
    }
    var spacingToMenuButtton = 12
    for item in floatingItems {
      item.snp.makeConstraints {
        $0.bottom.equalTo(menuButton.snp.top).inset(-spacingToMenuButtton)
        $0.trailing.equalTo(menuButton)
      }
      spacingToMenuButtton += 62
    }
  }

  override func setupUserInteraction() {
    self.menuButton.rx.tap.bind { [weak self] _ in
      guard let self = self else { return }
      self.isMenuOpend ? self.cloaseMenu() : self.openMenu()
    }
    .disposed(by: disposeBag)
  }

  // MARK: Binding

  func bind(reactor: Reactor) {
    self.bindAction(reactor)
    self.bindState(reactor)
  }
}

extension MoreViewController {
  private func bindAction(_ reactor: Reactor) {
    self.rx.viewWillAppear
      .withLatestFrom(RefreshCenter.shared.moreNeedRefresh)
      .filter { $0 }
      .map { _ in Reactor.Action.readAnalysis }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    coverView.button.rx.tap
      .map { _ in Reactor.Action.categoryInfoButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    floatingItems[0].buttonDidTap
      .do { AnalyticsManager.view_more_menu_accountManagement.log(nil) }
      .map { _ in Reactor.Action.accountManagementButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    floatingItems[1].buttonDidTap
      .do { AnalyticsManager.view_more_menu_opensourceLisence.log(nil) }
      .map { _ in Reactor.Action.opensourceButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    floatingItems[2].buttonDidTap
      .do { AnalyticsManager.view_more_menu_contact.log(nil) }
      .map { _ in Reactor.Action.contactButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }

  private func bindState(_ reactor: Reactor) {
    reactor.state.map { $0.didAnalysisUpdate }
      .bind(to: chartView.didAnalysisUpdate)
      .disposed(by: disposeBag)

    let title = Observable.combineLatest(reactor.state.map { $0.name }.distinctUntilChanged(),
                                         reactor.state.map { $0.total }.distinctUntilChanged())
    title.bind { [weak self] name, total in
      self?.titleLabel.text = name + String(format: LocalizedString.moreText.localized, total)
    }
    .disposed(by: disposeBag)

    reactor.state.map { $0.total }
      .map { $0 != 0 }
      .bind(to: placeholderView.rx.isHidden)
      .disposed(by: disposeBag)

    reactor.state.map { $0.total }
      .map { $0 == 0 }
      .bind(to: chartView.rx.isHidden)
      .disposed(by: disposeBag)
  }
}

extension MoreViewController {
  private func openMenu() {
    isMenuOpend = true
    menuButton.setImage(UIImage(.close), for: .normal)

    var delay = 0.0
    for item in floatingItems {
      item.isHidden = false
      UIView.animate(withDuration: 0.4, delay: delay, animations: { item.alpha = 1 })
      delay += 0.2
    }
    AnalyticsManager.view_more_menu.log(nil)
  }

  private func cloaseMenu() {
    isMenuOpend = false
    menuButton.setImage(UIImage(.menu), for: .normal)

    var delay = 0.0
    for item in floatingItems.reversed() {
      UIView.animate(withDuration: 0.4,
                     delay: delay,
                     animations: { item.alpha = 0 },
                     completion: { _ in item.isHidden = true })
      delay += 0.2
    }
  }
}
