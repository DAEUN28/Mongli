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
    case .homeIsRequired: return self.navigateToHome()
    default: return .none
    }
  }
}

// MARK: navigate functions
extension HomeFlow {
  private func navigateToHome() -> FlowContributors {
    let reactor = HomeViewReactor(self.service)
    let vc = HomeViewController(reactor)

    return .one(flowContributor: .contribute(withNextPresentable: vc,
                                             withNextStepper: reactor))
  }
}
