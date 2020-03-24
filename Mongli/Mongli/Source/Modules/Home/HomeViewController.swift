//
//  HomeViewController.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/20.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import FSCalendar
import ReactorKit
import RxCocoa
import RxFlow
import RxSwift

final class HomeViewController: BaseViewController, View, Stepper {

  typealias Reactor = HomeViewReactor

  // MARK: Properties

  var steps = PublishRelay<Step>()

  private let calendar = FSCalendar().then {
    $0.backgroundColor = .clear
    $0.appearance.headerDateFormat = LocalizedString.calendarHeaderDateFormat.localized
    $0.appearance.headerTitleColor = .white
    $0.appearance.headerTitleFont = FontManager.hpi20B
    $0.appearance.weekdayTextColor = .white
    $0.appearance.weekdayFont = FontManager.sys15B
    $0.appearance.titleDefaultColor = .white
    $0.appearance.titlePlaceholderColor = UIColor(hex: 0xC4C4C4)
    $0.appearance.titleTodayColor = themeService.attrs.primary
    $0.appearance.todayColor = .white
  }
  private let coverView = CoverView().then {
    $0.button.setUnderlineTitle(.deleteAllDream)
  }
  private let tableView = UITableView().then {
    $0.register(SummaryDreamTableViewCell.self, forCellReuseIdentifier: "SummaryDreamTableViewCell")
    $0.theme.backgroundColor = themed { $0.background }
  }
  private let createDreamButton = UIButton().then {
    $0.setImage(UIImage(.pencil), for: .normal)
    $0.layer.cornerRadius = 25
    $0.tintColor = .white
    $0.theme.backgroundColor = themed { $0.primary }
  }

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
    self.subViews = [self.calendar, self.coverView, self.tableView, self.createDreamButton]
  }

  override func setupConstraints() {
    self.calendar.snp.makeConstraints {
      $0.top.equalToSafeArea(self.view).inset(12)
      $0.bottom.equalTo(self.view.snp.centerY)
      $0.leading.equalToSuperview()
      $0.trailing.equalToSuperview()
    }
    self.coverView.snp.makeConstraints {
      $0.top.equalTo(self.calendar.snp.bottom)
      $0.bottom.equalToSafeArea(self.view)
      $0.leading.equalToSuperview()
      $0.trailing.equalToSuperview()
    }
    self.tableView.snp.makeConstraints {
      $0.top.equalTo(self.coverView.label.snp.bottom).offset(12)
      $0.bottom.equalToSafeArea(self.view)
      $0.leading.equalToSuperview().inset(24)
      $0.trailing.equalToSuperview().inset(24)
    }
    self.createDreamButton.snp.makeConstraints {
      $0.width.equalTo(50)
      $0.height.equalTo(50)
      $0.bottom.equalToSafeArea(self.view).inset(12)
      $0.trailing.equalToSafeArea(self.view).inset(12)
    }
  }

  override func setupUserInteraction() {
    let dreams = Observable.of([SummaryDream(id: 0, date: "2019-12-12", category: 0, title: "title", summary: "summary")])

    self.tableView.rowHeight = 56
    dreams.bind(to: self.tableView.rx.items(cellIdentifier: "SummaryDreamTableViewCell",
                                            cellType: SummaryDreamTableViewCell.self)) {
                                              $2.configure($1)
    }
  }

  // MARK: Binding

  func bind(reactor: Reactor) {
    self.bindAction(reactor)
    self.bindState(reactor)
  }
}

extension HomeViewController {
  private func bindAction(_ reactor: Reactor) {

  }

  private func bindState(_ reactor: Reactor) {

  }
}
