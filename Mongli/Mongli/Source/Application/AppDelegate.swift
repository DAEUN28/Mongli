//
//  AppDelegate.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/15.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import Firebase
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
  lazy var appFlow: AppFlow? = {
    guard let window = self.window else { return nil }
    return AppFlow(window: window, authService: self.authService, dreamService: self.dreamService)
  }()

  // MARK: App Life Cycle

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    if let flow = self.appFlow { self.setupFlow(flow) }
    FirebaseApp.configure()
    return true
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    if UITraitCollection.current.userInterfaceStyle == .dark {
      themeService.switch(.dark)
    } else {
      themeService.switch(.light)
    }
  }
}

extension AppDelegate {
  func setupFlow(_ flow: AppFlow) {
    self.coordinator.rx.willNavigate.bind { flow, step in
      log.info("will navigate to flow=\(flow) and step=\(step)")
    }
    .disposed(by: self.disposeBag)

    self.coordinator.rx.didNavigate.bind { flow, step in
      log.info("did navigate to flow=\(flow) and step=\(step)")
    }
    .disposed(by: self.disposeBag)

    self.coordinator.coordinate(flow: flow, with: AppStepper(self.authService))
  }
}
