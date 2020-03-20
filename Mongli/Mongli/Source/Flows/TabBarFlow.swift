//
//  TabBarFlow.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/20.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import RxFlow

// MARK: Flow
class TabBarFlow: Flow {
  var root: Presentable {
    return self.rootViewController
  }

  private let rootViewController = UITabBarController()
  private let authService: AuthService
  private let dreamService: DreamService

  init(authService: AuthService, dreamService: DreamService) {
    self.authService = authService
    self.dreamService = dreamService
  }

  deinit {
    log.info("DEINIT: TabBarFlow")
  }

  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? MongliStep else { return .none }

    switch step {
    case .userIsSignedIn:
      return self.navigateToHome()
    default:
      return .none
    }
  }
}

// MARK: navigate functions
extension TabBarFlow {
  private func navigateToHome() -> FlowContributors {
    let moreReactor = MoreViewReactor(self.authService)

    let homeFlow = HomeFlow(self.dreamService)
    let searchFlow = SearchFlow(self.dreamService)
    let moreFlow = MoreFlow(self.authService, reactor: moreReactor)

    Flows.whenReady(flow1: homeFlow, flow2: searchFlow, flow3: moreFlow) { [unowned self] home, search, more in

      let images = [("house", "house.fill"),
                    ("magnifyingglass", "magnifyingglass"),
                    ("ellipsis", "ellipsis")]

      for i in 0..<images.count {
        let image = UIImage(systemName: images[i].0)?.then {
          $0.applyingSymbolConfiguration(.init(weight: .medium))
          $0.withTintColor(.gray)
        }
        let selectedImage = UIImage(systemName: images[i].1)?.then {
          $0.applyingSymbolConfiguration(.init(weight: .medium))
          $0.withTintColor(.purple)
        }
        let item = UITabBarItem(title: nil, image: image, selectedImage: selectedImage)

        switch i {
        case 0: home.tabBarItem = item
        case 1: search.tabBarItem = item
        case 2: more.tabBarItem = item
        default: break
        }
      }

      self.rootViewController.setViewControllers([home, search, more], animated: false)
    }

    return .multiple(flowContributors: [.contribute(withNextPresentable: homeFlow,
                                                    withNextStepper: OneStepper(.homeIsRequired)),
                                        .contribute(withNextPresentable: searchFlow,
                                                    withNextStepper: OneStepper(.searchIsRequired)),
                                        .contribute(withNextPresentable: moreFlow,
                                                    withNextStepper: moreReactor)])
  }
}
