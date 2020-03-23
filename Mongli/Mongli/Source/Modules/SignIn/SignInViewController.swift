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
import RxCocoa
import RxFlow
import RxSwift

final class SignInViewController: BaseViewController, View, Stepper {

  typealias Reactor = SignInViewReactor

  // MARK: Properties

  var steps = PublishRelay<Step>()

  private let signInButton = ASAuthorizationAppleIDButton(type: .signIn, style: .white)
  private let logoView = LogoView()

  private let controller: ASAuthorizationController = {
    let request = ASAuthorizationAppleIDProvider().createRequest()
    request.requestedScopes = [.fullName]
    return ASAuthorizationController(authorizationRequests: [request])
  }()

  // MARK: initializing

  init(_ reactor: Reactor) {
    defer { self.reactor = reactor }
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

  override func setupConstraints() {
    self.signInButton.snp.makeConstraints {
      $0.height.equalTo(44)
      $0.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading).inset(40)
      $0.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing).inset(40)
      $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
    }
  }

  override func setupAction() {
    self.signInButton.rx.controlEvent(.touchUpInside)
      .subscribe(onNext: { [weak self] _ in
        self?.controller.performRequests()
      })
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
    self.controller.rx.didCompleteWithAuthorization
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

extension SignInViewController: ASAuthorizationControllerPresentationContextProviding {
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    self.view.window!
  }
}
