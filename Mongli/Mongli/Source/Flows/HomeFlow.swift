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

final class HomeFlow: DreamFlow {
  
  override func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? MongliStep else { return .none }

    switch step {
    case .homeIsRequired:
      return self.navigateToHome()

    default:
      return super.navigate(to: step)
    }
  }
}

// MARK: navigate functions

extension HomeFlow {
  private func navigateToHome() -> FlowContributors {
    let reactor = HomeViewReactor(self.service)
    let vc = HomeViewController(reactor)

    self.rootViewController.setViewControllers([vc], animated: false)
    return .one(flowContributor: .contribute(withNextPresentable: vc,
                                             withNextStepper: CompositeStepper(steppers: [vc, reactor]),
                                             allowStepWhenNotPresented: true))
  }
}
