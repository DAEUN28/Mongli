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

  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? MongliStep else { return .none }

    switch step {
    case .toast(let message):
      return self.showToast(message: message)

    case let .alert(type, handler):
      return self.presentAlert(type, handler: handler)

    case .categoryInfoIsRequired:
      return self.presentCategoryInfo()

    case .moreIsRequired:
      return self.navigateToMore()

    case .contactIsRequired:
      return self.presentContact()

    case .opensourceLisenceIsRequired:
      return self.presentOpensourceLisence()

    case let .accountManagementIsRequired(logoutHandler, deleteUserHandler, renameHandler):
      return self.presentAccountManagementActionSheet(logoutHandler, deleteUserHandler, renameHandler)

    default:
      return .none
    }
  }
}

// MARK: navigate functions

extension MoreFlow {
  private func showToast(message: LocalizedString) -> FlowContributors {
    self.rootViewController.showToast(message)
    return .none
  }

  private func presentAlert(_ type: UIViewController.AlertType,
                            handler: ((UIAlertAction) -> Void)?) -> FlowContributors {
    self.rootViewController.presentAlert(type, handler: handler)
    return .none
  }

  private func presentCategoryInfo() -> FlowContributors {
    let vc = CategoryInfoViewController()
    self.rootViewController.present(vc, animated: true)

    return .none
  }

  private func navigateToMore() -> FlowContributors {
    return .one(flowContributor: .contribute(withNextPresentable: self.rootViewController,
                                             withNextStepper: self.reactor))
  }

  private func presentContact() -> FlowContributors {
    return .none
  }

  private func presentOpensourceLisence() -> FlowContributors {
    return .none
  }

  private func presentAccountManagementActionSheet(_ logoutHandler: ((UIAlertAction) -> Void)?,
                                                   _ deleteUserHandler: ((UIAlertAction) -> Void)?,
                                                   _ renameHandler: @escaping ((String?) -> Void)) -> FlowContributors {
    let actionSheet = UIAlertController(title: .accountManagement, message: nil, style: .actionSheet)
    let logoutAction = UIAlertAction(title: .logout, style: .destructive, handler: logoutHandler)
    let deleteUserAction = UIAlertAction(title: .deleteUser, style: .destructive) { [unowned self] _ in
      self.rootViewController.presentAlert(.deleteUser, handler: deleteUserHandler)
    }
    let renameAction = UIAlertAction(title: .rename, style: .default) { [unowned self] _ in
      self.rootViewController.presentAlert(.rename(renameHandler))
    }

    actionSheet.addAction(logoutAction)
    actionSheet.addAction(deleteUserAction)
    actionSheet.addAction(renameAction)

    self.rootViewController.present(actionSheet, animated: true, completion: nil)

    return .none
  }
}
