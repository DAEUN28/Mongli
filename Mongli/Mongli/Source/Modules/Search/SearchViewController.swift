//
//  SearchViewController.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/20.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class SearchViewController: BaseViewController, View {

  typealias Reactor = SearchViewReactor

  // MARK: Properties

  let nokeywordSearch: PublishRelay<Void> = .init()

  // MARK: UI

  private let titleLabel = UILabel().then {
    $0.setText(.searchText)
    $0.setFont(.hpi20L)
    $0.theme.textColor = themed { $0.darkWhite }
  }
  private let searchBar = UISearchBar().then {
    $0.placeholder = LocalizedString.searchPlaceholder.localized
    $0.searchTextField.font = Font.sys16L.uifont
    $0.searchTextField.theme.backgroundColor = themed { $0.darkWhite }
    $0.barTintColor = .clear
    $0.backgroundColor = .clear
    $0.isTranslucent = true
    $0.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
  }
  private let filterButton = UIButton().then {
    $0.setImage(UIImage(.filter), for: .normal)
    $0.theme.tintColor = themed { $0.primary }
    $0.theme.backgroundColor = themed { $0.darkWhite }
    $0.layer.cornerRadius = 10
  }
  private let coverView = CoverView().then {
    $0.button.isHidden = true
  }
  private let tableView = UITableView().then {
    $0.register(SummaryDreamTableViewCell.self, forCellReuseIdentifier: "SummaryDreamTableViewCell")
    $0.rowHeight = 76
    $0.separatorStyle = .none
    $0.theme.backgroundColor = themed { $0.background }
  }
  private let refreshControl = UIRefreshControl().then {
    $0.theme.tintColor = themed { $0.primary }
  }
  private let placeholderView = PlaceholderView(.noSearchedContent)
  private let createDreamButton = UIButton().then {
    $0.setImage(UIImage(.pencil), for: .normal)
    $0.layer.cornerRadius = 25
    $0.tintColor = .white
    $0.theme.backgroundColor = themed { $0.primary }
  }
  private let spinner = Spinner()

  // MARK: Initializing

  init(_ reactor: Reactor) {
    super.init()
    self.reactor = reactor
    coverView.addSubview(placeholderView)
    tableView.refreshControl = refreshControl
    self.subViews = [titleLabel, searchBar, filterButton, coverView,
                     tableView, createDreamButton, spinner]
    self.setupUserInteraction()
  }

  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: View Life Cycle

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    AnalyticsManager.view_search.log(self.classForCoder.description())
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    searchBar.resignFirstResponder()
  }

  // MARK: Setup

  override func setupConstraints() {
    titleLabel.snp.makeConstraints {
      $0.top.equalToSafeArea(view).inset(20)
      $0.leading.equalToSuperview().inset(28)
    }
    searchBar.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(10)
      $0.leading.equalToSuperview().inset(20)
    }
    filterButton.snp.makeConstraints {
      $0.width.equalTo(filterButton.snp.height)
      $0.top.equalTo(searchBar.searchTextField.snp.top)
      $0.bottom.equalTo(searchBar.searchTextField.snp.bottom)
      $0.leading.equalTo(searchBar.snp.trailing).offset(12)
      $0.trailing.equalToSuperview().inset(28)
    }
    coverView.snp.makeConstraints {
      $0.top.equalTo(searchBar.searchTextField.snp.bottom).offset(20)
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
    searchBar.rx.searchButtonClicked
      .bind { [weak self] _ in self?.searchBar.resignFirstResponder() }
      .disposed(by: disposeBag)
  }

  // MARK: Binding

  func bind(reactor: Reactor) {
    bindAction(reactor)
    bindState(reactor)
  }
}

extension SearchViewController {
  private func bindAction(_ reactor: Reactor) {
    searchBar.rx.searchButtonClicked.withLatestFrom(searchBar.rx.text)
      .map { Reactor.Action.search($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    nokeywordSearch.map { Reactor.Action.search(nil) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    tableView.rx.itemSelected
      .map { Reactor.Action.selectDream($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    refreshControl.rx.controlEvent(.valueChanged)
      .map { _ in Reactor.Action.refresh }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    tableView.rx.prefetchRows
      .filter { $0.contains(where: { $0.row >= reactor.currentState.dreams.count - 1 }) }
      .map { _ in Reactor.Action.loadMore }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    filterButton.rx.tap
      .map { Reactor.Action.filterButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    createDreamButton.rx.tap
      .map { Reactor.Action.createButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }

  private func bindState(_ reactor: Reactor) {
    reactor.state.map { "\($0.total)" + LocalizedString.numberOfDreamsText.localized }
      .distinctUntilChanged()
      .bind(to: coverView.label.rx.text)
      .disposed(by: disposeBag)

    reactor.state.map { $0.dreams }
      .distinctUntilChanged()
      .bind(to: tableView.rx.items(cellIdentifier: "SummaryDreamTableViewCell",
                                   cellType: SummaryDreamTableViewCell.self)) { $2.configure($1) }
      .disposed(by: disposeBag)

    reactor.state.map { $0.dreams }
      .distinctUntilChanged()
      .map { !$0.isEmpty }
      .bind(to: placeholderView.rx.isHidden)
      .disposed(by: disposeBag)

    reactor.state.map { $0.dreams }
      .distinctUntilChanged()
      .map { $0.isEmpty }
      .bind(to: tableView.rx.isHidden)
      .disposed(by: disposeBag)

    reactor.state.map { $0.searchBarIsEnabled }
      .distinctUntilChanged()
      .bind(to: searchBar.rx.isUserInteractionEnabled)
      .disposed(by: disposeBag)

    reactor.state.map { $0.isRefreshing }
      .distinctUntilChanged()
      .bind(to: refreshControl.rx.isRefreshing )
      .disposed(by: disposeBag)

    reactor.state.map { $0.isLoading }
      .distinctUntilChanged()
      .bind(to: spinner.rx.isAnimating)
      .disposed(by: disposeBag)
  }
}
