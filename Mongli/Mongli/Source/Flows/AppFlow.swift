//
//  AppFlow.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/19.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import RxCocoa
import RxFlow
import RxSwift

// MARK: Flow
final class AppFlow: Flow {
  var root: Presentable {
    return self.rootWindow
  }

  private let rootWindow: UIWindow
  private let authService: AuthService
  private let dreamService: DreamService

  init(window: UIWindow, authService: AuthService, dreamService: DreamService) {
    self.rootWindow = window
    self.authService = authService
    self.dreamService = dreamService
  }

  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? MongliStep else { return .none }

    switch step {
    case .toast(let message):
      return self.showToast(message: message)

    case .signInIsRequired:
      return self.navigateToSignIn()

    case .userIsSignedIn:
      return self.navigateToTabBar()

    default:
      return .none
    }
  }
}

// MARK: navigate functions
extension AppFlow {
  private func showToast(message: LocalizedString) -> FlowContributors {
    self.rootWindow.rootViewController?.showToast(message)
    return .none
  }

  private func navigateToSignIn() -> FlowContributors {
    let reactor = SignInViewReactor(self.authService)
    let vc = SignInViewController(reactor)
    self.rootWindow.rootViewController = vc

    return .one(flowContributor: .contribute(withNext: vc))
  }

  private func navigateToTabBar() -> FlowContributors {
    let flow = TabBarFlow(authService: self.authService, dreamService: self.dreamService)

    Flows.whenReady(flow1: flow) { [unowned self] (root: UITabBarController) in
      self.rootWindow.rootViewController = root
    }

    return .one(flowContributor: .contribute(withNextPresentable: flow,
                                             withNextStepper: OneStepper(.userIsSignedIn)))
  }
}

// MARK: AppStepper
class AppStepper: Stepper {
  let steps = PublishRelay<Step>()
  private let service: AuthService
  private let disposeBag = DisposeBag()

  init(_ service: AuthService) {
    self.service = service
  }

  func readyToEmitSteps() {
    self.service.userIsSignedIn
      .map { $0 ? MongliStep.userIsSignedIn : MongliStep.signInIsRequired }
      .bind(to: steps)
      .disposed(by: self.disposeBag)
  }
}
