//
//  FilterViewController.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/04/04.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift

final class FilterViewController: UIViewController {

  // MARK: Properties

  let criteria = BehaviorRelay<Int>(value: 0)
  let alignment = BehaviorRelay<Int>(value: 0)
  let category = BehaviorRelay<Int?>(value: nil)
  let period = BehaviorRelay<String?>(value: nil)

  private var didSetupConstraints = false
  private let disposeBag = DisposeBag()

  // MARK: UI

  private let titleLabel = UILabel().then {
    $0.setText(.searchFilterText)
    $0.font = FontManager.hpi20L
    $0.theme.textColor = themed { $0.text }
  }
  private let criteriaLabel = UILabel().then {
    $0.setText(.criteria)
    $0.font = FontManager.sys17SB
    $0.theme.textColor = themed { $0.text }
  }
  private let criteriaSegmentedControl = UISegmentedControl().then {
    let criteria: [Criteria] = [.title, .content, .noKeyword]
    for criterion in criteria {
      $0.insertSegment(withTitle: criterion.toName().localized, at: criterion.rawValue, animated: false)
    }

    $0.selectedSegmentIndex = 0
    $0.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
    $0.theme.selectedSegmentTintColor = themed { $0.primary }
    $0.theme.segmentTitleAttribute = themed { $0.segmentedControlTitle }
  }
  private let alignmentLabel = UILabel().then {
    $0.setText(.alignment)
    $0.font = FontManager.sys17SB
    $0.theme.textColor = themed { $0.text }
  }
  private let alignmentSegmentedControl = UISegmentedControl().then {
    let alignments: [Alignment] = [.newest, .alphabetically]
    for alignment in alignments {
      $0.insertSegment(withTitle: alignment.toName().localized, at: alignment.rawValue, animated: false)
    }

    $0.selectedSegmentIndex = 0
    $0.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
    $0.theme.selectedSegmentTintColor = themed { $0.primary }
    $0.theme.segmentTitleAttribute = themed { $0.segmentedControlTitle }
  }
  private let categoryLabel = UILabel().then {
    $0.setText(.category)
    $0.font = FontManager.sys17SB
    $0.theme.textColor = themed { $0.text }
  }
  private let categoryButton = UIButton().then {
    $0.setTitle(.notSelect)
    $0.titleLabel?.font = FontManager.sys14B
    $0.theme.titleColor(from: themed { $0.text }, for: .normal)
  }
  private let periodLabel = UILabel().then {
    $0.setText(.period)
    $0.font = FontManager.sys17SB
    $0.theme.textColor = themed { $0.text }
  }
  private let periodView = PeriodView()
  private let doneButton = BottomButton(.filterApplyText)

  // MARK: View Life Cycle

  override func viewDidLoad() {
    self.view.theme.backgroundColor = themed { $0.background }

    self.view.addSubview(self.titleLabel)
    self.view.addSubview(self.criteriaLabel)
    self.view.addSubview(self.criteriaSegmentedControl)
    self.view.addSubview(self.alignmentLabel)
    self.view.addSubview(self.alignmentSegmentedControl)
    self.view.addSubview(self.categoryLabel)
    self.view.addSubview(self.categoryButton)
    self.view.addSubview(self.periodLabel)
    self.view.addSubview(self.periodView)
    self.view.addSubview(self.doneButton)

    self.categoryButton.rx.tap
      .bind { [weak self] in self?.presentCategoryPicker() }
      .disposed(by: self.disposeBag)
    Observable.combineLatest(self.periodView.startDate, self.periodView.endDate) { start, end -> String? in
      guard let start = start, let end = end else { return nil }
      return dateFormatter.string(from: start) + "~" + dateFormatter.string(from: end)
    }
    .compactMap { $0 }
    .bind(to: self.period)
    .disposed(by: self.disposeBag)
  }

  // MARK: Layout

  override func updateViewConstraints() {
    if !self.didSetupConstraints {

      self.titleLabel.snp.makeConstraints {
        $0.top.equalToSafeArea(self.view).inset(20)
        $0.leading.equalToSuperview().inset(20)
      }
      self.criteriaLabel.snp.makeConstraints {
        $0.top.equalTo(self.titleLabel.snp.bottom).offset(28)
        $0.leading.equalToSuperview().inset(28)
      }
      self.criteriaSegmentedControl.snp.makeConstraints {
        $0.centerY.equalTo(self.criteriaLabel.snp.centerY)
        $0.leading.equalTo(self.criteriaLabel.snp.trailing).offset(32)
        $0.trailing.equalToSuperview().inset(32)
      }
      self.alignmentLabel.snp.makeConstraints {
        $0.top.equalTo(self.criteriaLabel.snp.bottom).offset(36)
        $0.leading.equalTo(self.criteriaLabel.snp.leading)
      }
      self.alignmentSegmentedControl.snp.makeConstraints {
        $0.centerY.equalTo(self.alignmentLabel.snp.centerY)
        $0.leading.equalTo(self.criteriaSegmentedControl.snp.leading)
        $0.trailing.equalTo(self.criteriaSegmentedControl.snp.trailing)
      }
      self.categoryLabel.snp.makeConstraints {
        $0.top.equalTo(self.alignmentLabel.snp.bottom).offset(36)
        $0.leading.equalTo(self.alignmentLabel.snp.leading)
      }
      self.categoryButton.snp.makeConstraints {
        $0.centerY.equalTo(self.categoryLabel.snp.centerY)
        $0.centerX.equalTo(self.criteriaSegmentedControl.snp.centerX)
      }
      self.periodLabel.snp.makeConstraints {
        $0.top.equalTo(self.categoryLabel.snp.bottom).offset(36)
        $0.leading.equalTo(self.categoryLabel.snp.leading)
      }
      self.periodView.snp.makeConstraints {
        $0.centerY.equalTo(self.periodLabel.snp.centerY)
        $0.leading.equalTo(self.criteriaSegmentedControl.snp.leading)
        $0.trailing.equalTo(self.criteriaSegmentedControl.snp.trailing)
      }
      self.doneButton.snp.makeConstraints {
        $0.bottom.equalToSafeArea(self.view).inset(24)
        $0.leading.equalToSuperview().inset(32)
        $0.trailing.equalToSuperview().inset(32)
      }
      self.didSetupConstraints = true
    }
    super.updateViewConstraints()
  }
}

// MARK: Private Functions

extension FilterViewController {
  private func presentCategoryPicker() {
    let picker = UIPickerView()
    Observable.just(Category.categories)
      .bind(to: picker.rx.itemTitles) { return $1.toName().localized }
      .disposed(by: self.disposeBag)
    if let selectedRow = self.category.value {
      picker.selectRow(selectedRow, inComponent: 0, animated: false)
    }

    let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    let select = UIAlertAction(title: LocalizedString.select.localized, style: .default) { [weak self] _ in
      guard let selectedCategory = Category(rawValue: picker.selectedRow(inComponent: 0))?.toName() else { return }
      self?.category.accept(picker.selectedRow(inComponent: 0))
      self?.categoryButton.setTitle(selectedCategory)
    }
    let notSelect = UIAlertAction(title: LocalizedString.notSelect.localized, style: .default) { [weak self] _ in
      self?.category.accept(nil)
      self?.categoryButton.setTitle(.notSelect)
    }
    let cancel = UIAlertAction(title: LocalizedString.cancel.localized, style: .cancel)
    actionSheet.view.addSubview(picker)
    actionSheet.addAction(select)
    actionSheet.addAction(notSelect)
    actionSheet.addAction(cancel)

    actionSheet.view.snp.makeConstraints {
      $0.height.equalTo(320)
    }
    picker.snp.makeConstraints {
      $0.height.equalTo(150)
      $0.top.equalToSuperview()
      $0.leading.equalToSuperview()
      $0.trailing.equalToSuperview()
    }

    self.present(actionSheet, animated: true)
  }
}

private class PeriodView: UIView {

  let startDate = BehaviorRelay<Date?>(value: nil)
  let endDate = BehaviorRelay<Date?>(value: nil)

  private var didSetupConstraints = false
  private let disposeBag = DisposeBag()

  private let dashLabel = UILabel().then {
    $0.text = "~"
    $0.font = FontManager.sys14B
    $0.theme.textColor = themed { $0.text }
  }
  private let startDateButton = UIButton().then {
    $0.setTitle(.notSelect)
    $0.titleLabel?.font = FontManager.sys14B
    $0.theme.titleColor(from: themed { $0.text }, for: .normal)
  }
  private let endDateButton = UIButton().then {
    $0.setTitle(.notSelect)
    $0.titleLabel?.font = FontManager.sys14B
    $0.theme.titleColor(from: themed { $0.text }, for: .normal)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.addSubview(self.dashLabel)
    self.addSubview(self.startDateButton)
    self.addSubview(self.endDateButton)

    if let vc = self.superclass as? UIViewController {
      self.startDateButton.rx.tap
        .bind { [weak self] _ in
          vc.presentDatepickerActionSheet(select: self?.startDate.value) { self?.startDate.accept($0) }
        }
      .disposed(by: self.disposeBag)
      self.endDateButton.rx.tap
        .bind { [weak self] _ in
          vc.presentDatepickerActionSheet(select: self?.endDate.value) { self?.endDate.accept($0) }
        }
      .disposed(by: self.disposeBag)
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func updateConstraints() {
    if !self.didSetupConstraints {
      self.dashLabel.snp.makeConstraints {
        $0.centerX.equalToSuperview()
        $0.centerY.equalToSuperview()
      }
      self.startDateButton.snp.makeConstraints {
        $0.centerY.equalToSuperview()
        $0.trailing.equalTo(self.dashLabel.snp.leading).offset(-8)
      }
      self.endDateButton.snp.makeConstraints {
        $0.centerY.equalToSuperview()
        $0.leading.equalTo(self.dashLabel.snp.trailing).offset(8)
      }
      self.didSetupConstraints = true
    }
    super.updateConstraints()
  }
}
