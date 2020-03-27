//
//  ASAuthorizationAppleIDButton+Rx.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/21.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import AuthenticationServices

import RxSwift
import RxCocoa

typealias ASController = ASAuthorizationController
typealias ASControllerDelegate = ASAuthorizationControllerDelegate

extension Reactive where Base: ASController {
  var delegate: DelegateProxy<ASController, ASControllerDelegate> {
    return RxASControllerDelegate.proxy(for: self.base)
  }

  var didCompleteWithAuthorization: Observable<ASAuthorization?> {
    let selector = #selector(ASControllerDelegate.authorizationController(controller:didCompleteWithAuthorization:))
    return delegate.methodInvoked(selector)
      .map { $0[1] as? ASAuthorization }
  }
}

final class RxASControllerDelegate: DelegateProxy<ASController, ASControllerDelegate>,
DelegateProxyType, ASControllerDelegate {

  static func registerKnownImplementations() {
    self.register { RxASControllerDelegate(parentObject: $0, delegateProxy: self) }
  }

  static func currentDelegate(for object: ASController) -> ASControllerDelegate? {
    return object.delegate
  }

  static func setCurrentDelegate(_ delegate: ASControllerDelegate?, to object: ASController) {
    object.delegate = delegate
  }
}
