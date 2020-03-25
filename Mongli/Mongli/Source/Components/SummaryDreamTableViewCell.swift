//
//  SummaryDreamTableViewCell.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/24.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import SnapKit

final class SummaryDreamTableViewCell: UITableViewCell {

  // MARK: Properties

  private let dateFormatter = DateFormatter().then {
    $0.dateFormat = "yyyy.MM.dd"
  }

  // MARK: UI

  private let titleLabel = UILabel().then {
    $0.text = "title"
    $0.font = FontManager.sys12B
    $0.theme.textColor = themed { $0.text }
  }
  private let summaryLabel = UILabel().then {
    $0.text = "summary"
    $0.font = FontManager.sys10R
    $0.lineBreakMode = .byTruncatingTail
    $0.theme.textColor = themed { $0.text }
  }
  private let dateLabel = UILabel().then {
    $0.text = "yyyy.MM.dd"
    $0.font = FontManager.sys10M
    $0.isHidden = true
    $0.theme.textColor = themed { $0.text }
  }
  private let cloudImageView = UIImageView(image: UIImage(.cloud)).then {
    $0.theme.tintColor = themed { $0.text }
  }

  // MARK: Initializing

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.layer.cornerRadius = 10

    self.contentView.addSubview(self.titleLabel)
    self.contentView.addSubview(self.summaryLabel)
    self.contentView.addSubview(self.dateLabel)
    self.contentView.addSubview(self.cloudImageView)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Configuring

  func configure(_ dream: SummaryDream) {
    if let backgroundColor = Category(rawValue: dream.category)?.toColor() {
      self.backgroundColor = backgroundColor
    }
    if let dateString = dream.date,
      let date = self.dateFormatter.date(from: dateString) {
      self.dateLabel.text = self.dateFormatter.string(from: date)
      self.dateLabel.isHidden = false
    }
    self.titleLabel.text = dream.title
    self.summaryLabel.text = dream.summary
  }

  // MARK: Layout

  override func layoutSubviews() {
    self.titleLabel.sizeToFit()
    self.summaryLabel.sizeToFit()
    self.dateLabel.sizeToFit()

    self.cloudImageView.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.trailing.equalToSuperview().inset(12)
      $0.width.equalTo(20)
      $0.height.equalTo(20)
    }
    self.titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(12)
      $0.leading.equalToSuperview().inset(12)
    }
    self.dateLabel.snp.makeConstraints {
      $0.bottom.equalTo(self.titleLabel.snp.bottom)
      $0.leading.equalTo(self.titleLabel.snp.trailing).offset(8)
    }
    self.summaryLabel.snp.makeConstraints {
      $0.top.equalTo(self.titleLabel.snp.bottom).offset(4)
      $0.bottom.equalToSuperview().inset(12)
      $0.leading.equalTo(self.titleLabel.snp.leading)
      $0.trailing.equalTo(self.cloudImageView.snp.leading).inset(8)
    }
  }

}
