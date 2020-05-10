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
  private let endDateLabel = UILabel().then {
    $0.setText(.endDateText)
    $0.setFont(.sys10L)
    $0.theme.textColor = themed { $0.darkWhite }
  }
  private let spinner = Spinner()

  // MARK: Initializing

  init(_ reactor: Reactor, appleIDProvider: ASAuthorizationAppleIDProvider) {
    let request = appleIDProvider.createRequest()
    request.requestedScopes = [.fullName]
    asController = ASAuthorizationController(authorizationRequests: [request])

    super.init()
    self.reactor = reactor
    self.subViews = [logoView, signInButton, spinner, endDateLabel]
    self.setupUserInteraction()
  }

  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: View Life Cycle

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    AnalyticsManager.view_signIn.log(self.classForCoder.description())
  }

  // MARK: Setup

  override func setupConstraints() {
    UIView.animate(withDuration: 2) {
      self.logoView.backgroundColor = .white
      self.signInButton.transform = CGAffineTransform(translationX: 0, y: -60)
    }

    signInButton.snp.makeConstraints {
      $0.height.equalTo(44)
      $0.leading.equalTo(view.snp.leading).inset(40)
      $0.trailing.equalTo(view.snp.trailing).inset(40)
      $0.bottom.equalTo(view.snp.bottom)
    }
    endDateLabel.snp.makeConstraints {
      $0.centerX.equalTo(signInButton.snp.centerX)
      $0.bottom.equalTo(signInButton.snp.top).offset(8)
    }
  }

  override func setupUserInteraction() {
    signInButton.rx.controlEvent(.touchUpInside)
      .bind { [weak self] _ in self?.asController.performRequests()  }
      .disposed(by: disposeBag)
  }

  // MARK: Binding

  func bind(reactor: Reactor) {
    // action
    asController.rx.didCompleteWithAuthorization
      .map { Reactor.Action.signIn($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    // state
    reactor.state.map { $0.isLoading }
      .bind(to: spinner.rx.isAnimating)
      .disposed(by: disposeBag)
  }
}

// MARK: ASAuthorizationControllerPresentationContextProviding

extension SignInViewController: ASAuthorizationControllerPresentationContextProviding {
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    return view.window!
  }
}
