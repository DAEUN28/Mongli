//
//  FilterViewController.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/04/04.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import FSCalendar
import RxCocoa
import RxSwift

final class FilterViewController: UIViewController {

  // MARK: Properties

  let criteria = BehaviorRelay<Int>(value: 0)
  let alignment = BehaviorRelay<Int>(value: 0)
  let category = BehaviorRelay<Int?>(value: nil)
  let period = BehaviorRelay<String?>(value: nil)

  private var didSetupConstraints = false

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
    $0.theme.tintColor = themed { $0.primary }
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
    $0.theme.tintColor = themed { $0.primary }
  }
  private let categoryLabel = UILabel().then {
    $0.setText(.category)
    $0.font = FontManager.sys17SB
    $0.theme.textColor = themed { $0.text }
  }
  private let categoryPicker = UIPickerView()
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
    self.view.addSubview(self.categoryPicker)
    self.view.addSubview(self.calendar)
    self.view.addSubview(self.doneButton)

    self.calendar.delegate = self
  }

  // MARK: Layout

  override func updateViewConstraints() {
    if !self.didSetupConstraints {
      self.categoryLabel.sizeToFit()

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
        $0.leading.equalTo(self.categoryPicker.snp.leading)
        $0.trailing.equalTo(self.categoryPicker.snp.trailing)
      }
      self.alignmentLabel.snp.makeConstraints {
        $0.top.equalTo(self.criteriaLabel.snp.bottom).offset(36)
        $0.leading.equalTo(self.criteriaLabel.snp.leading)
      }
      self.alignmentSegmentedControl.snp.makeConstraints {
        $0.centerY.equalTo(self.alignmentLabel.snp.centerY)
        $0.leading.equalTo(self.categoryPicker.snp.leading)
        $0.trailing.equalTo(self.categoryPicker.snp.trailing)
      }
      self.categoryLabel.snp.makeConstraints {
        $0.top.equalTo(self.alignmentLabel.snp.bottom).offset(36)
        $0.leading.equalTo(self.alignmentLabel.snp.leading)
      }
      self.categoryPicker.snp.makeConstraints {
        $0.width.equalTo(32)
        $0.centerY.equalTo(self.alignmentLabel.snp.centerY)
        $0.leading.equalTo(self.categoryLabel.snp.trailing).offset(12)
        $0.trailing.equalToSuperview().inset(32)
      }
      self.calendar.snp.makeConstraints {
        $0.top.equalTo(self.categoryPicker.snp.bottom).offset(40)
        $0.bottom.equalTo(self.doneButton.snp.top).offset(-40)
        $0.leading.equalToSuperview().inset(28)
        $0.trailing.equalToSuperview().inset(28)
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

// MARK: FSCalendarDelegate

extension FilterViewController: FSCalendarDelegate {
  func calendar(_ calendar: FSCalendar,
                shouldSelect date: Date,
                at monthPosition: FSCalendarMonthPosition) -> Bool {
    return monthPosition == .current
  }

  func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
    print(date)
  }
}
