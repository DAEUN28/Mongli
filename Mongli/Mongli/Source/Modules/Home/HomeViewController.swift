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

  private let monthlyDreams = BehaviorRelay<MonthlyDreams>(value: MonthlyDreams())
  private let didSelectDate = PublishRelay<Date>()
  private let currentPageDidChange = PublishRelay<Date>()

  // MARK: UI

  private let calendar = FSCalendar().then {
    $0.backgroundColor = .clear
    $0.appearance.headerDateFormat = LocalizedString.calendarHeaderDateFormat.localized
    $0.appearance.headerTitleColor = .white
    $0.appearance.headerTitleFont = FontManager.hpi20B
    $0.appearance.weekdayTextColor = .white
    $0.appearance.weekdayFont = FontManager.sys15B
    $0.appearance.caseOptions = .weekdayUsesSingleUpperCase
    $0.appearance.titleDefaultColor = .white
    $0.appearance.titlePlaceholderColor = UIColor(hex: 0xC4C4C4)
    $0.appearance.todayColor = .white
    $0.appearance.theme.titleTodayColor = themed { $0.primary }
    $0.appearance.selectionColor = .white
    $0.appearance.theme.titleSelectionColor = themed { $0.primary }
    $0.allowsMultipleSelection = false
  }
  private let coverView = CoverView().then {
    $0.button.setUnderlineTitle(.deleteAllDream)
  }
  private let tableView = UITableView().then {
    $0.register(SummaryDreamTableViewCell.self, forCellReuseIdentifier: "SummaryDreamTableViewCell")
    $0.rowHeight = UITableView.automaticDimension
    $0.theme.backgroundColor = themed { $0.background }
  }
  private let placeholderView = PlaceholderView(.noContent)
  private let createDreamButton = UIButton().then {
    $0.setImage(UIImage(.pencil), for: .normal)
    $0.layer.cornerRadius = 25
    $0.tintColor = .white
    $0.theme.backgroundColor = themed { $0.primary }
  }
  private let spinner = Spinner()

  // MARK: initializing

  init(_ reactor: Reactor) {
    defer { self.reactor = reactor }
    super.init()

    self.calendar.delegate = self
    self.calendar.dataSource = self
  }

  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: View Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    self.coverView.addSubview(self.placeholderView)
    self.subViews = [self.calendar,
                     self.coverView,
                     self.tableView,
                     self.createDreamButton,
                     self.spinner]
  }

  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.setNavigationBarHidden(true, animated: true)
  }

  // MARK: Setup

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
    self.createDreamButton.rx.tap
      .map { MongliStep.createDreamIsRequired }
      .bind(to: self.steps)
      .disposed(by: self.disposeBag)
  }

  // MARK: Binding

  func bind(reactor: Reactor) {
    self.bindAction(reactor)
    self.bindState(reactor)
  }
}

extension HomeViewController {
  private func bindAction(_ reactor: Reactor) {
    self.didSelectDate
      .map { Reactor.Action.selectDate($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    self.currentPageDidChange
      .map { Reactor.Action.selectMonth($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    self.coverView.button.rx.tap
      .withLatestFrom(Observable.just(self.calendar.selectedDate))
      .compactMap { $0 }
      .map { dateFormatter.string(from: $0) }
      .map { MongliStep.alert(.delete($0),
                              title: .allTheDreamsOfDateFormat,
                              message: .deleteDreamDesc) { [weak self] _ in
                                guard let self = self else { return }
                                Observable.just(Reactor.Action.deleteAllDreams)
                                  .bind(to: reactor.action)
                                  .disposed(by: self.disposeBag) }}
      .bind(to: self.steps)
      .disposed(by: self.disposeBag)
      self.tableView.rx.itemSelected
        .map { Reactor.Action.selectDream($0) }
        .bind(to: reactor.action)
        .disposed(by: self.disposeBag)
  }

  private func bindState(_ reactor: Reactor) {
    reactor.state.map { $0.selectedDate }
      .map { LocalizedString.aDreamOfDateFormat.localizedDateString($0) }
      .bind(to: self.coverView.label.rx.text)
      .disposed(by: self.disposeBag)
    reactor.state.map { $0.dailyDreams }
      .bind(to: self.tableView.rx.items(cellIdentifier: "SummaryDreamTableViewCell",
                                        cellType: SummaryDreamTableViewCell.self)) { $2.configure($1) }
      .disposed(by: self.disposeBag)
    reactor.state.map { $0.dailyDreamsIsEmpty }
      .map { !$0 }
      .bind(to: self.placeholderView.rx.isHidden)
      .disposed(by: self.disposeBag)
    reactor.state.map { $0.dailyDreamsIsEmpty }
      .bind(to: self.tableView.rx.isHidden)
      .disposed(by: self.disposeBag)
    reactor.state.map { $0.dailyDreamsIsEmpty }
      .bind(to: self.coverView.button.rx.isHidden)
      .disposed(by: self.disposeBag)
    reactor.state.map { $0.monthlyDreams }
      .do(onNext: { [weak self] _ in self?.calendar.reloadData() })
      .bind(to: self.monthlyDreams)
      .disposed(by: self.disposeBag)
    reactor.state.map { $0.isDeletedAllDreams }
      .filter { $0 }
      .map { _ in MongliStep.toast(.deletedMsg) }
      .bind(to: self.steps)
      .disposed(by: self.disposeBag)
    reactor.state.map { $0.selectedDreamID }
      .compactMap { $0 }
      .map { MongliStep.readDreamIsRequired($0) }
      .bind(to: self.steps)
      .disposed(by: self.disposeBag)
    reactor.state.map { $0.error }
      .compactMap { $0 }
      .map { MongliStep.toast($0) }
      .bind(to: self.steps)
      .disposed(by: self.disposeBag)
    reactor.state.map { $0.isLoading }
      .bind(to: self.spinner.rx.isAnimating)
      .disposed(by: self.disposeBag)
  }
}

// MARK: FSCalendarDelegate

extension HomeViewController: FSCalendarDelegateAppearance, FSCalendarDataSource {
  func calendar(_ calendar: FSCalendar,
                appearance: FSCalendarAppearance,
                eventDefaultColorsFor date: Date) -> [UIColor]? {
    let key = dateFormatter.string(from: date)
    guard let categories = self.monthlyDreams.value[key] else { return nil }
    return categories.compactMap { Category(rawValue: $0)?.toColor() }
  }

  func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
    let key = dateFormatter.string(from: date)
    guard let categories = self.monthlyDreams.value[key] else { return 0 }
    return categories.count
  }

  func calendar(_ calendar: FSCalendar,
                shouldSelect date: Date,
                at monthPosition: FSCalendarMonthPosition) -> Bool {
    return monthPosition == .current
  }

  func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
    self.didSelectDate.accept(date)
  }

  func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
    self.currentPageDidChange.accept(calendar.currentPage)
  }
}
