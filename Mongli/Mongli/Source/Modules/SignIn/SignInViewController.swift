//
//  SignInViewController.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/15.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import AuthenticationServices
import UIKit

import Hero
import ReactorKit
import RxSwift
import RxCocoa

final class SignInViewController: BaseViewController, View {

  typealias Reactor = SignInViewReactor

  // MARK: Properties

  var reactor: Reactor?

  private let signInButton = ASAuthorizationAppleIDButton(type: .signIn, style: .white)
  private let logoView = LogoView()

  // MARK: initializing

  init(_ reactor: Reactor) {
    self.reactor = reactor
  }

  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: View Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    self.subViews = [self.logoView, self.signInButton]

    UIView.animate(withDuration: 3) {
      self.logoView.backgroundColor = .white
      self.signInButton.transform = CGAffineTransform(translationX: 0, y: -60)
    }
  }

  override func setupConstraints() {
    self.logoView.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
    self.signInButton.snp.makeConstraints {
      $0.height.equalTo(44)
      $0.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading).inset(40)
      $0.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing).inset(40)
      $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
    }
  }

  func bind(reactor: Reactor) {

  }
}
