//
//  DreamFlow.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/04/10.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import RxCocoa
import RxFlow
import RxSwift

// MARK: Flow

class DreamFlow: Flow {
  
  var root: Presentable {
    return self.rootViewController
  }

  let rootViewController = UINavigationController().then {
    $0.setNavigationBarHidden(true, animated: false)
  }
  let service: DreamService

  init(_ service: DreamService) {
    self.service = service
  }

  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? MongliStep else { return .none }

    switch step {
    case .toast(let message):
      return self.showToast(message: message)

    case let .alert(type, title, message, handler):
      return self.presentAlert(type, title: title, message: message, handler: handler)

    case .datePickerActionSheet(let handler):
      return self.presentDatepickerActionSheet(handler)

    case .dismiss:
      return self.dismiss()

    case .categoryInfoIsRequired:
      return self.navigateToCategoryInfo()

    case .createDreamIsRequired:
      return self.navigateToCreateDream()

    case .readDreamIsRequired(let id):
      return self.navigateToReadDream(id)

    case .updateDreamIsRequired(let dream):
      return self.navigateToUpdateDream(dream)

    case .updateDreamIsComplete(let dream):
      return self.navigateToReadDream(dream)

    default:
      return .none
    }
  }
}

// MARK: navigate functions

extension DreamFlow {
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

  private func presentDatepickerActionSheet(_ handler: @escaping (Date) -> Void) -> FlowContributors {
    self.rootViewController.topViewController?.presentDatepickerActionSheet(handler)
    return .none
  }

  private func dismiss() -> FlowContributors {
    self.rootViewController.popViewController(animated: false)
    return .none
  }

  private func navigateToCreateDream() -> FlowContributors {
    let reactor = CreateDreamViewReactor(self.service)
    let vc = CreateDreamViewController(reactor)
    vc.hidesBottomBarWhenPushed = true

    self.rootViewController.pushViewController(vc, animated: true)
    return .one(flowContributor: .contribute(withNext: vc))
  }

  private func navigateToReadDream(_ id: Int) -> FlowContributors {
    let reactor = ReadDreamViewReactor(self.service, id: id)
    let vc = ReadDreamViewController(reactor)
    vc.hidesBottomBarWhenPushed = true

    self.rootViewController.pushViewController(vc, animated: true)
    return .one(flowContributor: .contribute(withNext: vc))
  }

  private func navigateToUpdateDream(_ dream: Dream) -> FlowContributors {
    let reactor = UpdateDreamViewReactor(self.service, dream: dream)
    let vc = UpdateDreamViewController(reactor)
    vc.hidesBottomBarWhenPushed = true

    self.rootViewController.pushViewController(vc, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: vc,
                                             withNextStepper: CompositeStepper(steppers: [vc, reactor]),
                                             allowStepWhenNotPresented: true))
  }

  private func navigateToReadDream(_ dream: Dream) -> FlowContributors {
    self.rootViewController.popViewController(animated: true)
    guard let vc = self.rootViewController.topViewController as? ReadDreamViewController else { return .none }
    vc.setupDream(dream)

    return .none
  }

  private func navigateToCategoryInfo() -> FlowContributors {
    let vc = CategoryInfoViewController()
    self.rootViewController.topViewController?.present(vc, animated: true)

    return .none
  }
}
