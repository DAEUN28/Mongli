//
//  AuthService.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/18.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

import RxSwift

final class AuthService: Service, AuthServiceType {
  var currentUserAnalysis: UserAnalysis? {
    return DatabaseManager.read(.analysis) as? UserAnalysis
  }

  var userIsSignedIn: Observable<Bool> {
    return .just(currentUserInfo != nil)
  }

  func logout() -> BasicResult {
    return revokeToken()
  }

  func deleteUser() -> BasicResult {
    return provider.rx.request(.deleteUser)
      .asObservable()
      .filterSuccessfulStatusCodes()
      .map { _ -> LocalizedString? in
        if DatabaseManager.deleteAll() { return nil }
        return .unknownErrorMsg
      }
      .catchErrorJustReturn(.retryMsg)
  }

  func rename(_ name: String) -> BasicResult {
    return provider.rx.request(.rename(name))
      .asObservable()
      .filterSuccessfulStatusCodes()
      .map { [weak self] _ -> LocalizedString? in
        if let object = self?.currentUserInfo {
          object.name = name
          if DatabaseManager.update(.info, object: object) { return nil }
          return .unknownErrorMsg
        }
        return .notFoundUserForcedLogoutMsg
      }
      .catchError { [unowned self] in self.catchMongliError($0) }
  }

  func readAnalysis() -> AnalysisResult {
    return provider.rx.request(.readAnalysis)
      .asObservable()
      .filterSuccessfulStatusCodes()
      .map(UserAnalysis.self)
      .map { userAnalysis -> (UserAnalysis?, LocalizedString?) in
        if DatabaseManager.update(.analysis, object: userAnalysis) { return (userAnalysis, nil) }
        return (nil, .unknownErrorMsg)
      }
      .catchError { [unowned self] in self.catchMongliError($0).map { (nil, $0) } }
  }
}
