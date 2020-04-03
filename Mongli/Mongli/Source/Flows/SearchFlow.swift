//
//  SearchFlow.swift
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
final class SearchFlow: Flow {
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

  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? MongliStep else { return .none }

    switch step {
    case .searchIsRequired:
      return self.navigateToSearch()
      
    default: return .none
    }
  }
}

// MARK: navigate functions
extension SearchFlow {
  private func navigateToSearch() -> FlowContributors {
    let reactor = SearchViewReactor(self.service)
    let vc = SearchViewController(reactor)

    self.rootViewController.setViewControllers([vc], animated: false)
    return .one(flowContributor: .contribute(withNext: vc))
  }
}
