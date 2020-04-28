//
//  ChartView.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/04/13.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift

final class ChartView: UIView {

  // MARK: Properties

  var didAnalysisUpdate = BehaviorRelay<Bool>(value: false)

  private let disposeBag = DisposeBag()
  private var barUnitWidth: Int {
    guard let analysisCounts = self.analysisCounts, let max = analysisCounts.max() else { return 0 }
    if self.frame == .zero || max < 12 { return 20 }
    let barMaxWidth = (self.frame.maxX - 16) - self.lineView.frame.maxX
    return Int(barMaxWidth) / max
  }
  private var analysisCounts: [Int]? {
    guard let analysis = StorageManager.shared.readAnalysis() else { return nil }
    return [analysis.red, analysis.orange, analysis.yellow, analysis.green,
            analysis.teal, analysis.blue, analysis.indigo, analysis.purple]
  }

  // MARK: UI

  private let nameStackView = UIStackView().then {
    $0.axis = .vertical
    $0.alignment = .fill
    $0.distribution = .fillEqually
    $0.spacing = 36
    $0.translatesAutoresizingMaskIntoConstraints = false

    for category in Category.categories {
      let nameLabel = UILabel()
      nameLabel.setText(category.toName())
      nameLabel.font = FontManager.sys14L
      nameLabel.textAlignment = .right
      nameLabel.theme.textColor = themed { $0.primary }
      $0.addArrangedSubview(nameLabel)
    }
  }
  private let lineView = UIView().then {
    $0.theme.backgroundColor = themed { $0.primary }
  }
  private let barChartStackView = UIStackView().then {
    $0.axis = .vertical
    $0.alignment = .fill
    $0.distribution = .fillEqually
    $0.spacing = 36
    $0.translatesAutoresizingMaskIntoConstraints = false
  }

  // MARK: Initializing

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.addSubview(nameStackView)
    self.addSubview(lineView)
    self.addSubview(barChartStackView)

    self.setupConstraints()

    didAnalysisUpdate
      .filter { $0 }
      .bind { [unowned self] _ in self.setNeedsLayout() }
      .disposed(by: disposeBag)
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Layout

  private func setupConstraints() {
    nameStackView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(8)
      $0.bottom.equalToSuperview().inset(8)
      $0.leading.equalToSuperview()
    }
    lineView.snp.makeConstraints {
      $0.width.equalTo(1)
      $0.top.equalToSuperview()
      $0.bottom.equalToSuperview()
      $0.leading.equalTo(self.nameStackView.snp.trailing).offset(8)
    }
    barChartStackView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(8)
      $0.bottom.equalToSuperview().inset(8)
      $0.leading.equalTo(self.lineView.snp.trailing)
      $0.trailing.equalToSuperview()
    }
  }

  override func layoutSubviews() {
    guard let analysisCounts = self.analysisCounts else { return }
    if barChartStackView.arrangedSubviews.count < 1 { return self.setUpBarChartStackView() }

    for i in 0..<barChartStackView.arrangedSubviews.count {
      let barView = barChartStackView.arrangedSubviews[i].subviews[0]
      let countLabel = barChartStackView.arrangedSubviews[i].subviews[1] as? UILabel
      countLabel?.text = "\(analysisCounts[i])"
      barView.snp.remakeConstraints {
        $0.width.equalTo(analysisCounts[i] * self.barUnitWidth)
        $0.height.equalTo(20)
        $0.centerY.equalToSuperview()
        $0.leading.equalToSuperview()
      }
    }

    didAnalysisUpdate.accept(false)
    RefreshCenter.shared.moreNeedRefresh.accept(false)
  }
}

// MARK: private funcion

extension ChartView {
  private func setUpBarChartStackView() {
    guard let analysisCounts = self.analysisCounts else { return }

    func makeBarView(_ category: Category, count: Int) -> UIView {
      let containerView = UIView()
      let barView = UIView()
      let countLabel = UILabel()

      barView.backgroundColor = category.toColor()
      countLabel.text = "\(count)"
      countLabel.font = FontManager.sys12T
      countLabel.theme.textColor = themed { $0.primary }

      containerView.addSubview(barView)
      containerView.addSubview(countLabel)

      barView.snp.makeConstraints {
        $0.width.equalTo(self.barUnitWidth * count)
        $0.height.equalTo(20)
        $0.centerY.equalToSuperview()
        $0.leading.equalToSuperview()
      }
      countLabel.snp.makeConstraints {
        $0.centerY.equalToSuperview()
        $0.leading.equalTo(barView.snp.trailing).offset(4)
      }

      return containerView
    }

    for i in 0..<analysisCounts.count {
      guard let category = Category(rawValue: i) else { return }
      let barView = makeBarView(category, count: analysisCounts[i])
      self.barChartStackView.addArrangedSubview(barView)
    }
  }
}
