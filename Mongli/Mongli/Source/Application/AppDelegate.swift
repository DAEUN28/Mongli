//
//  AppDelegate.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/15.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import RxFlow
import RxSwift
import RxCocoa

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  var coordinator = FlowCoordinator()
  private let disposeBag = DisposeBag()

  private let authService = AuthService()
  private let dreamService = DreamService()

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    guard let window = self.window else { return false }

    self.coordinator.rx.willNavigate.subscribe(onNext: { flow, step in
      log.info("will navigate to flow=\(flow) and step=\(step)")
    })
    .disposed(by: self.disposeBag)

    self.coordinator.rx.didNavigate.subscribe(onNext: { flow, step in
      log.info("did navigate to flow=\(flow) and step=\(step)")
    })
    .disposed(by: self.disposeBag)

    let appFlow = AppFlow(window: window, authService: self.authService, dreamService: self.dreamService)

    self.coordinator.coordinate(flow: appFlow, with: AppStepper(self.authService))

    return true
  }
}
