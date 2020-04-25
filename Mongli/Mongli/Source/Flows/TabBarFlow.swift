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

  private let rootViewController = UITabBarController().then {
    $0.tabBar.theme.tintColor = themed { $0.primary }
    $0.tabBar.isTranslucent = false
  }
  private let authService: AuthService
  private let dreamService: DreamService

  init(authService: AuthService, dreamService: DreamService) {
    self.authService = authService
    self.dreamService = dreamService
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
    let homeFlow = HomeFlow(self.dreamService)
    let searchFlow = SearchFlow(self.dreamService)
    let moreFlow = MoreFlow(self.authService)

    Flows.whenReady(flow1: homeFlow, flow2: searchFlow, flow3: moreFlow) { [unowned self] home, search, more in

      let keys: [SFSymbolKey] = [.house, .magnifyingglass, .ellipsis]

      for i in 0..<keys.count {
        let image = UIImage(keys[i])
        let item = UITabBarItem(title: nil, image: image, selectedImage: nil)

        switch i {
        case 0:
          home.tabBarItem = item
          home.title = LocalizedString.home.localized

        case 1:
          search.tabBarItem = item
          search.title = LocalizedString.search.localized

        case 2:
          more.tabBarItem = item
          more.title = LocalizedString.more.localized

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
                                                    withNextStepper: OneStepper(.moreIsRequired))])
  }
}
