//
//  HomeFlow.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/20.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import RxCocoa
import RxFlow
import RxSwift

// MARK: Flow
final class HomeFlow: Flow {
  var root: Presentable {
    return self.rootViewController
  }

  private let rootViewController = UINavigationController().then {
    $0.setNavigationBarHidden(true, animated: false)
  }

  private let service: DreamService

  init(_ service: DreamService) {
    self.service = service
  }

  deinit {
    log.info("DEINIT: AppFlow")
  }

  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? MongliStep else { return .none }

    switch step {
    case .toast(let message):
      return self.showToast(message: message)

    case let .alert(type, title, message, handler):
      return presentAlert(type, title: title, message: message, handler: handler)

    case .homeIsRequired:
      return self.navigateToHome()

    case .createDreamIsRequired:
      return self.navigateToCreateDream()

    case .readDreamIsRequired(let id):
      return self.navigateToReadDream(id)

    default:
      return .none
    }
  }
}

// MARK: navigate functions
extension HomeFlow {
  private func showToast(message: LocalizedString) -> FlowContributors {
    self.rootViewController.topViewController?.showToast(message)
    return .none
  }

  private func presentAlert(_ type: UIViewController.AlertType,
                            title: LocalizedString?,
                            message: LocalizedString?,
                            handler: ((UIAlertAction) -> Void)?) -> FlowContributors {
    self.rootViewController.topViewController?.presentAlert(type,
                                                            title: title,
                                                            message: message,
                                                            handler: handler)
    return .none
  }

  private func navigateToHome() -> FlowContributors {
    let reactor = HomeViewReactor(self.service)
    let vc = HomeViewController(reactor)

    self.rootViewController.setViewControllers([vc], animated: false)
    return .one(flowContributor: .contribute(withNext: vc))
  }

  private func navigateToCreateDream() -> FlowContributors {
    let reactor = CreateDreamViewReactor(self.service)
    let vc = CreateDreamViewController(reactor)

    self.rootViewController.pushViewController(vc, animated: false)
    return .one(flowContributor: .contribute(withNext: vc))
  }

  private func navigateToReadDream(_ id: Int) -> FlowContributors {
    let reactor = ReadDreamViewReactor(self.service, id: id)
    let vc = ReadDreamViewController(reactor)

    self.rootViewController.pushViewController(vc, animated: false)
    return .one(flowContributor: .contribute(withNext: vc))
  }
}
