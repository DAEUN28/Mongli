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

final class SearchFlow: DreamFlow {

  override func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? MongliStep else { return .none }

    switch step {
    case .searchIsRequired:
      return self.navigateToSearch()

    case .filterIsRequired(let query):
      return self.presentFilter(query)

    case .filterIsComplete(let query):
      return self.dismissFilter(query)

    default:
      return super.navigate(to: step)
    }
  }
}

// MARK: navigate functions

extension SearchFlow {
  private func navigateToSearch() -> FlowContributors {
    let reactor = SearchViewReactor(self.service)
    let vc = SearchViewController(reactor)

    self.rootViewController.setViewControllers([vc], animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: vc,
                                             withNextStepper: reactor))
  }

  private func presentFilter(_ query: SearchQuery) -> FlowContributors {
    let vc = FilterViewController(query)

    self.rootViewController.topViewController?.present(vc, animated: true)
    return .one(flowContributor: .contribute(withNext: vc))
  }

  private func dismissFilter(_ query: SearchQuery) -> FlowContributors {
    self.rootViewController.visibleViewController?.dismiss(animated: true)
    guard let vc = self.rootViewController.topViewController as? SearchViewController else { return .none }
    vc.reactor?.searchQuery.accept(query)

    return .none
  }
}
