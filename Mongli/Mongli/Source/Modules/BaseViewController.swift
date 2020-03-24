//
//  BaseViewController.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/19.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation
import UIKit

import RxTheme
import RxCocoa
import RxSwift

class BaseViewController: UIViewController {

  // MARK: Properties

  lazy private var className: String = {
    return type(of: self).description().components(separatedBy: ".").last ?? ""
  }()

  var disposeBag = DisposeBag()
  var subViews: [UIView]? {
    willSet {
      guard let views = newValue else { return }
      for view in views {
        self.view.addSubview(view)
      }
    }
  }

  // MARK: Initializing

  init() {
    super.init(nibName: nil, bundle: nil)
  }

  required convenience init?(coder aDecoder: NSCoder) {
    self.init()
  }

  deinit {
    log.info("DEINIT: \(self.className)")
  }

  // MARK: Layout Constraints

  private(set) var didNotSetupConstraints = true

  override func viewDidLoad() {
    self.view.setNeedsUpdateConstraints()
    self.setupViews()
    self.setupUserInteraction()
    self.setupBackground()
  }

  override func updateViewConstraints() {
    if self.didNotSetupConstraints {
      self.setupConstraints()
      self.didNotSetupConstraints = false
    }
    super.updateViewConstraints()
  }

  func setupConstraints() { }

  // MARK: Setup

  func setupViews() { }
  func setupUserInteraction() { }

  private func setupBackground() {
    self.view.layer.theme.backgroundGradient = themed { $0.gradient }
  }
}
