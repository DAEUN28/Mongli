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
import RxFlow
import RxSwift

final class SignInViewController: BaseViewController, View, Stepper {

  typealias Reactor = SignInViewReactor

  // MARK: Properties

  var steps = PublishRelay<Step>()

  private let asController: ASAuthorizationController

  // MARK: UI
  private let signInButton = ASAuthorizationAppleIDButton(type: .signIn, style: .white)
  private let logoView = LogoView()

  // MARK: Initializing

  init(_ reactor: Reactor, appleIDProvider: ASAuthorizationAppleIDProvider) {
    defer { self.reactor = reactor }
    let request = appleIDProvider.createRequest()
    request.requestedScopes = [.fullName]
    self.asController = ASAuthorizationController(authorizationRequests: [request])

    super.init()
  }

  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: View Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    self.subViews = [self.logoView, self.signInButton]

    UIView.animate(withDuration: 2) {
      self.logoView.backgroundColor = .white
      self.signInButton.transform = CGAffineTransform(translationX: 0, y: -60)
    }
  }

  // MARK: Setup

  override func setupConstraints() {
    self.signInButton.snp.makeConstraints {
      $0.height.equalTo(44)
      $0.leading.equalTo(self.view.snp.leading).inset(40)
      $0.trailing.equalTo(self.view.snp.trailing).inset(40)
      $0.bottom.equalTo(self.view.snp.bottom)
    }
  }

  override func setupUserInteraction() {
    self.signInButton.rx.controlEvent(.touchUpInside)
      .bind { [weak self] _ in
        self?.asController.performRequests()
      }
      .disposed(by: self.disposeBag)
  }

  // MARK: Binding

  func bind(reactor: Reactor) {
    self.bindAction(reactor)
    self.bindState(reactor)
  }
}

extension SignInViewController {
  private func bindAction(_ reactor: Reactor) {
    self.asController.rx.didCompleteWithAuthorization
      .map { Reactor.Action.signIn($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
  }

  private func bindState(_ reactor: Reactor) {
    reactor.state.map { $0.isSignedIn }
      .filter { $0 }
      .map { _ in MongliStep.userIsSignedIn }
      .bind(to: self.steps)
      .disposed(by: self.disposeBag)
    reactor.state.map { $0.error }
      .filter { $0 != nil }
      .map { MongliStep.toast($0!) }
      .bind(to: self.steps)
      .disposed(by: self.disposeBag)
  }
}

// MARK: ASAuthorizationControllerPresentationContextProviding

extension SignInViewController: ASAuthorizationControllerPresentationContextProviding {
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    self.view.window!
  }
}
