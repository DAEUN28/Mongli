//
//  SummaryDreamTableViewCell.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/24.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import SnapKit
import Then

final class SummaryDreamTableViewCell: UITableViewCell {

  // MARK: Properties

  private let dateFormatter = DateFormatter().then {
    $0.dateFormat = "yyyy.MM.dd"
  }
  private var didLayoutSubviews = false

  // MARK: UI

  private let containerView = UIView()
  private let titleLabel = UILabel().then {
    $0.text = "title"
    $0.setFont(.sys12B)
    $0.textColor = .white
  }
  private let summaryLabel = UILabel().then {
    $0.text = "summary"
    $0.setFont(.sys10R)
    $0.lineBreakMode = .byTruncatingTail
    $0.textColor = .white
  }
  private let dateLabel = UILabel().then {
    $0.text = "yyyy.MM.dd"
    $0.setFont(.sys10M)
    $0.isHidden = true
    $0.textColor = .white
  }
  private let cloudImageView = UIImageView(image: UIImage(.cloud)).then {
    $0.tintColor = .white
  }

  // MARK: Initializing

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.backgroundColor = .clear
    self.selectionStyle = .none
    containerView.layer.cornerRadius = 10

    contentView.addSubview(containerView)
    containerView.addSubview(titleLabel)
    containerView.addSubview(summaryLabel)
    containerView.addSubview(dateLabel)
    containerView.addSubview(cloudImageView)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Configuring

  func configure(_ dream: SummaryDream) {
    if let backgroundColor = Category(rawValue: dream.category)?.toColor() {
      containerView.backgroundColor = backgroundColor
    }
    if let dateString = dream.date,
      let date = dateFormatter.date(from: dateString) {
      dateLabel.text = dateFormatter.string(from: date)
      dateLabel.isHidden = false
    }
    titleLabel.text = dream.title
    summaryLabel.text = dream.summary
  }

  // MARK: Layout

  override func layoutSubviews() {
    if didLayoutSubviews { return }
    containerView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(10)
      $0.bottom.equalToSuperview().inset(10)
      $0.leading.equalToSuperview()
      $0.trailing.equalToSuperview()
    }
    cloudImageView.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.trailing.equalToSuperview().inset(12)
      $0.width.equalTo(20)
      $0.height.equalTo(20)
    }
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(12)
      $0.leading.equalToSuperview().inset(12)
    }
    dateLabel.snp.makeConstraints {
      $0.bottom.equalTo(titleLabel.snp.bottom)
      $0.leading.equalTo(titleLabel.snp.trailing).offset(8)
    }
    summaryLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(4)
      $0.bottom.equalToSuperview().inset(12)
      $0.leading.equalTo(titleLabel.snp.leading)
      $0.trailing.equalTo(cloudImageView.snp.leading).offset(-8)
    }
    didLayoutSubviews = true
  }
}
