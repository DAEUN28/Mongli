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
import RxFlow
import RxSwift

final class SearchViewController: BaseViewController, View, Stepper {

  typealias Reactor = SearchViewReactor

  // MARK: Properties

  var steps = PublishRelay<Step>()

  // MARK: UI
  private let titleLabel = UILabel().then {
    $0.setText(.searchText)
    $0.font = FontManager.hpi20L
    $0.theme.textColor = themed { $0.darkWhite }
  }
  private let searchBar = UISearchBar().then {
    $0.placeholder = LocalizedString.searchPlaceholder.localized
    $0.searchTextField.font = FontManager.sys16L
    $0.searchTextField.theme.backgroundColor = themed { $0.darkWhite }
    $0.barTintColor = UIColor.clear
    $0.backgroundColor = UIColor.clear
    $0.isTranslucent = true
    $0.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
  }
  private let filterButton = UIButton().then {
    $0.setImage(UIImage(.filter), for: .normal)
    $0.theme.tintColor = themed { $0.primary }
    $0.theme.backgroundColor = themed { $0.darkWhite }
    $0.layer.cornerRadius = 10
  }
  private let filterVC = FilterViewController()
  private let coverView = CoverView().then {
    $0.button.isHidden = true
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
  }

  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: View Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    self.coverView.addSubview(self.placeholderView)
    self.subViews = [self.titleLabel,
                     self.searchBar,
                     self.filterButton,
                     self.coverView,
                     self.tableView,
                     self.createDreamButton,
                     self.spinner]
  }

  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.setNavigationBarHidden(true, animated: false)
  }

  // MARK: Setup

  override func setupConstraints() {
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
    self.filterButton.rx.tap
      .bind { [weak self] _ in
        guard let self = self else { return }
        self.present(self.filterVC, animated: true)
      }
      .disposed(by: self.disposeBag)
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

extension SearchViewController {
  private func bindAction(_ reactor: Reactor) {
//    self.date
//      .map { Reactor.Action.selectDate($0) }
//      .bind(to: reactor.action)
//      .disposed(by: self.disposeBag)
//    self.currentPageDidChange
//      .map { Reactor.Action.selectMonth($0) }
//      .bind(to: reactor.action)
//      .disposed(by: self.disposeBag)
//    self.coverView.button.rx.tap
//      .withLatestFrom(self.date)
//      .compactMap { $0 }
//      .map { dateFormatter.string(from: $0) }
//      .map { MongliStep.alert(.delete($0)) { [weak self] _ in
//        guard let self = self else { return }
//        Observable.just(Reactor.Action.deleteAllDreams)
//          .bind(to: reactor.action)
//          .disposed(by: self.disposeBag)
//        }
//      }
//      .bind(to: self.steps)
//      .disposed(by: self.disposeBag)
//    self.tableView.rx.itemSelected
//      .map { Reactor.Action.selectDream($0) }
//      .bind(to: reactor.action)
//      .disposed(by: self.disposeBag)
  }

  private func bindState(_ reactor: Reactor) {
//    reactor.state.map { $0.isLoading }
//      .distinctUntilChanged()
//      .bind(to: self.spinner.rx.isAnimating)
//      .disposed(by: self.disposeBag)
  }
}
