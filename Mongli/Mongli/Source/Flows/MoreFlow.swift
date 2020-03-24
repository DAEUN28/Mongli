//
//  MoreFlow.swift
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
final class MoreFlow: Flow {
  var root: Presentable {
    return self.rootViewController
  }

  lazy private var rootViewController = {
    return MoreViewController(self.reactor)
  }()

  private let reactor: MoreViewReactor
  private let service: AuthService

  init(_ service: AuthService) {
    self.service = service
    self.reactor = MoreViewReactor(service)
  }

  deinit {
    log.info("DEINIT: AppFlow")
  }

  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? MongliStep else { return .none }

    switch step {
    case .moreIsRequired: return self.navigateToMore()
    default: return .none
    }
  }
}

// MARK: navigate functions
extension MoreFlow {
  private func navigateToMore() -> FlowContributors {
    return .one(flowContributor: .contribute(withNext: self.rootViewController))
  }
}
