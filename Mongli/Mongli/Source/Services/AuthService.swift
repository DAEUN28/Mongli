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
      .filterSuccessfulStatusCodes()
      .map { _ -> NetworkResult in
        if DatabaseManager.deleteAll() { return .success }
        return .error(.unknown)
      }
      .catchErrorJustReturn(.error(.unknown))
  }

  func rename(_ name: String) -> BasicResult {
    return provider.rx.request(.rename(name))
      .filterSuccessfulStatusCodes()
      .map { [unowned self] _ -> NetworkResult in
        if let object = self.currentUserInfo {
          object.name = name
          if DatabaseManager.update(.info, object: object) { return .success }
          return .error(.unknown)
        }
        return .error(.notFound)
      }
      .catchError { [unowned self] in self.catchMongliError($0) }
  }

  func readAnalysis() -> AnalysisResult {
    return provider.rx.request(.readAnalysis)
      .filterSuccessfulStatusCodes()
      .map(UserAnalysis.self)
      .map {
        if DatabaseManager.update(.analysis, object: $0) { return .success($0) }
        return .error(.unknown)
      }
      .catchError { [unowned self] in
        self.catchMongliError($0)
          .map { result -> NetworkResultWithValue<UserAnalysis> in
            switch result {
            case .success: return .error(.unknown)
            case .error(let err): return .error(err)
            }
        }
      }
  }
}
