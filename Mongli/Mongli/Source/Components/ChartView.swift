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
    $0.alignment = .trailing
    $0.distribution = .fillEqually
    $0.spacing = 36
    $0.translatesAutoresizingMaskIntoConstraints = false

    for category in Category.categories {
      let nameLabel = UILabel()
      nameLabel.setText(category.toName())
      nameLabel.font = FontManager.sys14L
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

    if let analysisCounts = self.analysisCounts {
      for i in 0..<analysisCounts.count {
        guard let category = Category(rawValue: i) else { return }
        let stackView = self.makeBarStackView(category, count: analysisCounts[i])
        self.barChartStackView.addArrangedSubview(stackView)
      }
    }

    self.addSubview(nameStackView)
    self.addSubview(lineView)
    self.addSubview(barChartStackView)

    self.setupConstraints()

    didAnalysisUpdate.bind { [weak self] in
      if $0 { self?.setNeedsLayout() }
    }
    .disposed(by: disposeBag)
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Layout

  private func setupConstraints() {
    self.nameStackView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(8)
      $0.bottom.equalToSuperview().inset(8)
      $0.leading.equalToSuperview()
    }
    self.lineView.snp.makeConstraints {
      $0.width.equalTo(1)
      $0.top.equalToSuperview()
      $0.bottom.equalToSuperview()
      $0.leading.equalTo(self.nameStackView.snp.trailing).offset(8)
    }
    self.barChartStackView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(8)
      $0.bottom.equalToSuperview().inset(8)
      $0.leading.equalTo(self.lineView.snp.trailing)
      $0.trailing.equalToSuperview()
    }
  }

  override func layoutSubviews() {
    if didAnalysisUpdate.value {
      guard let analysisCounts = self.analysisCounts else { return }
      for i in 0..<self.barChartStackView.arrangedSubviews.count {
        guard let barStackView = self.barChartStackView.arrangedSubviews[i] as? UIStackView else { return }
        let barView = barStackView.arrangedSubviews[0]
        barView.frame.size.width = CGFloat((analysisCounts[i] * self.barUnitWidth))
      }
      self.didAnalysisUpdate.accept(false)
      UserDefaults.standard.set(false, forKey: "needAnalysisUpdate")
    }
  }
}

// MARK: private funcion

extension ChartView {
  private func makeBarStackView(_ category: Category, count: Int) -> UIStackView {
    let stackView = UIStackView()
    let barView = UIView(frame: .init(origin: .zero,
                                      size: .init(width: self.barUnitWidth * count, height: 20)))
    let countLabel = UILabel()

    stackView.axis = .horizontal
    stackView.alignment = .leading
    stackView.distribution = .fillEqually
    stackView.spacing = 4
    barView.backgroundColor = category.toColor()
    countLabel.text = "\(count)"
    countLabel.theme.textColor = themed { $0.primary }

    stackView.addArrangedSubview(barView)
    stackView.addArrangedSubview(countLabel)

    return stackView
  }
}
