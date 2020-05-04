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

  var disposeBag: DisposeBag = .init()
  var subViews: [UIView]? {
    willSet {
      guard let views = newValue else { return }
      for view in views {
        self.view.addSubview(view)
      }
    }
  }

  private var didSetupConstraints = false

  // MARK: Initializing

  init() {
    super.init(nibName: nil, bundle: nil)
  }

  required convenience init?(coder aDecoder: NSCoder) {
    self.init()
  }

  deinit {
    log.verbose("DEINIT: \(self.classForCoder.description())")
  }

  // MARK: Layout Constraints

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.layer.theme.backgroundGradient = themed { $0.gradient }
  }

  override func updateViewConstraints() {
    if !didSetupConstraints {
      self.setupConstraints()
      didSetupConstraints = true
    }
    super.updateViewConstraints()
  }

  func setupConstraints() { }

  // MARK: Setup

  func setupUserInteraction() { }

  func setupDreamNavigationBar() {
    self.navigationController?.setNavigationBarHidden(false, animated: false)
    self.navigationController?.navigationBar.theme.tintColor = themed { $0.darkWhite }
    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    self.navigationController?.navigationBar.clipsToBounds = true
    self.navigationController?.navigationBar.theme.titleTextAttributes = themed { $0.navigationBarTitle }

    let backButton = UIBarButtonItem(image: UIImage(.back), style: .plain, target: nil, action: nil)
    self.navigationItem.leftBarButtonItem = backButton
    backButton.rx.tap
      .bind { [weak self] in self?.navigationController?.popViewController(animated: true) }
      .disposed(by: disposeBag)

    self.navigationController?.interactivePopGestureRecognizer?.delegate = self
  }

  func addCalendarBarButton() -> UIBarButtonItem {
    let button = UIBarButtonItem(image: UIImage(.calendar), style: .plain, target: nil, action: nil)
    self.navigationItem.rightBarButtonItem = button

    return button
  }
}

extension BaseViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                         shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return false
  }
}
