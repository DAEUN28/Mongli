//
//  SignInViewController.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/15.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import AuthenticationServices
import UIKit

import ReactorKit
import RxCocoa
import RxSwift

final class SignInViewController: BaseViewController, View {

  typealias Reactor = SignInViewReactor

  // MARK: Properties

  private let asController: ASAuthorizationController

  // MARK: UI

  private let signInButton = ASAuthorizationAppleIDButton(type: .signIn, style: .white)
  private let logoView = LogoView()

  // MARK: Initializing

  init(_ reactor: Reactor, appleIDProvider: ASAuthorizationAppleIDProvider) {
    defer { self.reactor = reactor }
    let request = appleIDProvider.createRequest()
    request.requestedScopes = [.fullName]
    asController = ASAuthorizationController(authorizationRequests: [request])

    super.init()

    self.subViews = [logoView, signInButton]
  }

  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Setup

  override func setupConstraints() {
    UIView.animate(withDuration: 2) { [weak self] in
      self?.logoView.backgroundColor = .white
      self?.signInButton.transform = CGAffineTransform(translationX: 0, y: -60)
    }

    signInButton.snp.makeConstraints {
      $0.height.equalTo(44)
      $0.leading.equalTo(view.snp.leading).inset(40)
      $0.trailing.equalTo(view.snp.trailing).inset(40)
      $0.bottom.equalTo(view.snp.bottom)
    }
  }

  override func setupUserInteraction() {
    signInButton.rx.controlEvent(.touchUpInside)
      .bind { [weak self] _ in self?.asController.performRequests()  }
      .disposed(by: disposeBag)
  }

  // MARK: Binding

  func bind(reactor: Reactor) {
    asController.rx.didCompleteWithAuthorization
    .map { Reactor.Action.signIn($0) }
    .bind(to: reactor.action)
    .disposed(by: disposeBag)
  }
}

// MARK: ASAuthorizationControllerPresentationContextProviding

extension SignInViewController: ASAuthorizationControllerPresentationContextProviding {
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    view.window!
  }
}
