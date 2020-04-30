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
    defer { self.reactor = reactor }
    super.init()
  }

  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: View Life Cycle

  override func viewDidAppear(_ animated: Bool) {
    self.navigationController?.setNavigationBarHidden(true, animated: true)
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.searchBar.resignFirstResponder()
  }

  // MARK: Setup

  override func setupConstraints() {
    self.coverView.addSubview(self.placeholderView)
    self.tableView.refreshControl = self.refreshControl
    self.subViews = [self.titleLabel,
                     self.searchBar,
                     self.filterButton,
                     self.coverView,
                     self.tableView,
                     self.createDreamButton,
                     self.spinner]

    self.titleLabel.snp.makeConstraints {
      $0.top.equalToSafeArea(self.view).inset(20)
      $0.leading.equalToSuperview().inset(28)
    }
    self.searchBar.snp.makeConstraints {
      $0.top.equalTo(self.titleLabel.snp.bottom).offset(10)
      $0.leading.equalToSuperview().inset(20)
    }
    self.filterButton.snp.makeConstraints {
      $0.width.equalTo(self.filterButton.snp.height)
      $0.top.equalTo(self.searchBar.searchTextField.snp.top)
      $0.bottom.equalTo(self.searchBar.searchTextField.snp.bottom)
      $0.leading.equalTo(self.searchBar.snp.trailing).offset(12)
      $0.trailing.equalToSuperview().inset(28)
    }
    self.coverView.snp.makeConstraints {
      $0.top.equalTo(self.searchBar.searchTextField.snp.bottom).offset(20)
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
    self.searchBar.rx.searchButtonClicked
      .bind { [weak self] _ in
        self?.searchBar.resignFirstResponder()
      }
      .disposed(by: self.disposeBag)
  }

  // MARK: Binding

  func bind(reactor: Reactor) {
    self.bindAction(reactor)
    self.bindState(reactor)
  }
}

extension SearchViewController {
  private func bindAction(_ reactor: Reactor) {
    self.searchBar.rx.searchButtonClicked.withLatestFrom(self.searchBar.rx.text)
      .map { Reactor.Action.search($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.tableView.rx.itemSelected
      .map { Reactor.Action.selectDream($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.refreshControl.rx.controlEvent(.valueChanged)
      .map { _ in Reactor.Action.refresh }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.tableView.rx.prefetchRows
      .filter { $0.contains(where: { $0.row >= reactor.currentState.dreams.count }) }
      .map { _ in Reactor.Action.loadMore }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.filterButton.rx.tap
      .map { Reactor.Action.presentFilter }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.createDreamButton.rx.tap
      .map { Reactor.Action.navigateToCreateDream }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
  }

  private func bindState(_ reactor: Reactor) {
    reactor.state.map { "\($0.total)" + LocalizedString.numberOfDreamsText.localized }
      .distinctUntilChanged()
      .bind(to: self.coverView.label.rx.text)
      .disposed(by: self.disposeBag)

    reactor.state.map { $0.dreams }
      .distinctUntilChanged()
      .bind(to: self.tableView.rx.items(cellIdentifier: "SummaryDreamTableViewCell",
                                        cellType: SummaryDreamTableViewCell.self)) { $2.configure($1) }
      .disposed(by: self.disposeBag)

    reactor.state.map { $0.dreams }
      .distinctUntilChanged()
      .map { !$0.isEmpty }
      .bind(to: self.placeholderView.rx.isHidden)
      .disposed(by: self.disposeBag)

    reactor.state.map { $0.dreams }
      .distinctUntilChanged()
      .map { $0.isEmpty }
      .bind(to: self.tableView.rx.isHidden)
      .disposed(by: self.disposeBag)

    reactor.state.map { $0.searchBarIsEnabled }
      .distinctUntilChanged()
      .bind(to: self.searchBar.rx.isUserInteractionEnabled)
      .disposed(by: self.disposeBag)

    reactor.state.map { $0.isRefreshing }
      .distinctUntilChanged()
      .bind(to: self.refreshControl.rx.isRefreshing )
      .disposed(by: self.disposeBag)

    reactor.state.map { $0.isLoading }
      .distinctUntilChanged()
      .bind(to: self.spinner.rx.isAnimating)
      .disposed(by: self.disposeBag)
  }
}
