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
import RxSwift

final class HomeViewController: BaseViewController, View {

  typealias Reactor = HomeViewReactor

  // MARK: Properties

  private let date: BehaviorRelay<Date> = .init(value: Date())
  private let month: BehaviorRelay<Date> = .init(value: Date())
  private let monthlyDreams: BehaviorRelay<MonthlyDreams?> = .init(value: nil)

  // MARK: UI

  private let calendar = FSCalendar().then {
    $0.backgroundColor = .clear
    $0.appearance.headerDateFormat = LocalizedString.calendarHeaderDateFormat.localized
    $0.appearance.headerTitleColor = .white
    $0.appearance.headerTitleFont = Font.hpi20B.uifont
    $0.appearance.weekdayTextColor = .white
    $0.appearance.weekdayFont = Font.sys15B.uifont
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
    $0.rowHeight = 76
    $0.separatorStyle = .none
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

  // MARK: Initializing

  init(_ reactor: Reactor) {
    defer { self.reactor = reactor }
    super.init()

    calendar.delegate = self
    calendar.dataSource = self
  }

  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidAppear(_ animated: Bool) {
    navigationController?.setNavigationBarHidden(true, animated: false)
  }

  // MARK: Setup

  override func setupConstraints() {
    coverView.addSubview(placeholderView)
    self.subViews = [calendar, coverView, tableView, createDreamButton, spinner]

    calendar.snp.makeConstraints {
      $0.top.equalToSafeArea(view).inset(12)
      $0.bottom.equalTo(view.snp.centerY)
      $0.leading.equalToSuperview()
      $0.trailing.equalToSuperview()
    }
    coverView.snp.makeConstraints {
      $0.top.equalTo(calendar.snp.bottom)
      $0.bottom.equalToSafeArea(view)
      $0.leading.equalToSuperview()
      $0.trailing.equalToSuperview()
    }
    tableView.snp.makeConstraints {
      $0.top.equalTo(coverView.label.snp.bottom).offset(12)
      $0.bottom.equalToSafeArea(view)
      $0.leading.equalToSuperview().inset(24)
      $0.trailing.equalToSuperview().inset(24)
    }
    createDreamButton.snp.makeConstraints {
      $0.width.equalTo(50)
      $0.height.equalTo(50)
      $0.bottom.equalToSafeArea(view).inset(12)
      $0.trailing.equalToSafeArea(view).inset(12)
    }
  }

  override func setupUserInteraction() {
    date.distinctUntilChanged()
      .map { LocalizedString.dateFormat.localizedDate($0, .dreamAdverb) }
      .bind(to: coverView.label.rx.text)
      .disposed(by: disposeBag)
  }

  // MARK: Binding

  func bind(reactor: Reactor) {
    bindAction(reactor)
    bindState(reactor)
  }
}

extension HomeViewController {
  private func bindAction(_ reactor: Reactor) {
    let needRefresh = rx.viewWillAppear
      .withLatestFrom(RefreshCenter.shared.homeNeedRefresh.filter { $0 })

    Observable.merge(needRefresh.withLatestFrom(date), date.asObservable())
      .map { Reactor.Action.selectDate($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    Observable.merge(needRefresh.withLatestFrom(month), month.asObservable())
      .map { Reactor.Action.selectMonth($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    coverView.button.rx.tap
      .withLatestFrom(date)
      .compactMap { $0 }
      .map { Reactor.Action.deleteAllDreamsButtonDidTap($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    tableView.rx.itemSelected
      .map { Reactor.Action.selectDream($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    createDreamButton.rx.tap
      .map { Reactor.Action.createDreamButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }

  private func bindState(_ reactor: Reactor) {
    reactor.state.map { $0.dailyDreams }
      .distinctUntilChanged()
      .bind(to: tableView.rx.items(cellIdentifier: "SummaryDreamTableViewCell",
                                   cellType: SummaryDreamTableViewCell.self)) { $2.configure($1) }
      .disposed(by: disposeBag)

    reactor.state.map { $0.dailyDreams }
      .distinctUntilChanged()
      .map { !$0.isEmpty }
      .bind(to: placeholderView.rx.isHidden)
      .disposed(by: disposeBag)

    reactor.state.map { $0.dailyDreams }
      .distinctUntilChanged()
      .map { $0.isEmpty }
      .bind(to: tableView.rx.isHidden)
      .disposed(by: disposeBag)

    reactor.state.map { $0.dailyDreams }
      .distinctUntilChanged()
      .map { $0.isEmpty }
      .bind(to: coverView.button.rx.isHidden)
      .disposed(by: disposeBag)

    reactor.state.map { $0.monthlyDreams }
      .distinctUntilChanged()
      .do(onNext: { [weak self] _ in self?.calendar.reloadData() })
      .bind(to: monthlyDreams)
      .disposed(by: disposeBag)

    reactor.state.map { $0.isLoading }
      .distinctUntilChanged()
      .bind(to: spinner.rx.isAnimating)
      .disposed(by: disposeBag)
  }
}

// MARK: FSCalendarDelegate

extension HomeViewController: FSCalendarDelegateAppearance, FSCalendarDataSource {
  func calendar(_ calendar: FSCalendar,
                appearance: FSCalendarAppearance,
                eventDefaultColorsFor date: Date) -> [UIColor]? {
    let key = dateFormatter.string(from: date)
    guard let categories = monthlyDreams.value?[key] else { return nil }
    return categories.compactMap { Category(rawValue: $0)?.toColor() }
  }

  func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
    let key = dateFormatter.string(from: date)
    guard let categories = monthlyDreams.value?[key] else { return 0 }
    return categories.count
  }

  func calendar(_ calendar: FSCalendar,
                shouldSelect date: Date,
                at monthPosition: FSCalendarMonthPosition) -> Bool {
    return monthPosition == .current
  }

  func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
    self.date.accept(date)
  }

  func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
    month.accept(calendar.currentPage)
  }
}
