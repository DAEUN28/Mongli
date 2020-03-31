//
//  BaseViewController.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/19.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation
import UIKit

import RxCocoa
import RxSwift
import RxTheme

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

  func setupDreamNavigationBar(dateString: String) {
    let date = Observable.just(dateFormatter.date(from: dateString)).compactMap { $0 }
      .asDriver(onErrorJustReturn: Date())
    self.setupDreamNavigationBar(date: date).isEnabled = false
  }

  func setupDreamNavigationBar(date: Driver<Date>) -> UIBarButtonItem {
    self.navigationController?.setNavigationBarHidden(false, animated: true)
    self.navigationController?.navigationBar.theme.tintColor = themed { $0.darkWhite }
    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    self.navigationController?.navigationBar.clipsToBounds = true

    self.navigationController?.navigationBar.theme.titleTextAttributes = themed { $0.navigationBarTitle }
    date.map { LocalizedString.aDreamOfDateFormat.localizedDate($0) }
      .drive(self.rx.title)
      .disposed(by: self.disposeBag)

    let button = UIBarButtonItem(image: UIImage(.calendar), style: .plain, target: nil, action: nil)
    self.navigationItem.rightBarButtonItem = button

    return button
  }

  private func setupBackground() {
    self.view.layer.theme.backgroundGradient = themed { $0.gradient }
  }
}
