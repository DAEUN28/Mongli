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
  var currentUserAnalysis: Analysis? {
    return StorageManager.shared.readAnalysis()
  }

  var userIsSignedIn: Observable<Bool> {
    return .just(currentUser != nil)
  }

  func logout() -> BasicResult {
    return revokeToken()
  }

  func deleteUser() -> BasicResult {
    return provider.rx.request(.deleteUser)
      .timeout(RxTimeInterval.seconds(2), scheduler: MainScheduler.instance)
      .filterSuccessfulStatusCodes()
      .map { _ -> NetworkResult in
        if StorageManager.shared.deleteAll() { return .success }
        return .error(.unknown)
      }
      .catchErrorJustReturn(.error(.unknown))
  }

  func rename(_ name: String) -> BasicResult {
    return provider.rx.request(.rename(name))
      .timeout(RxTimeInterval.seconds(2), scheduler: MainScheduler.instance)
      .filterSuccessfulStatusCodes()
      .map { [unowned self] _ -> NetworkResult in
        if var user = self.currentUser {
          user.name = name
          if StorageManager.shared.updateUser(user) { return .success }
          return .error(.unknown)
        }
        return .error(.notFound)
      }
      .catchError { [unowned self] in self.catchMongliError($0) }
  }

  func readAnalysis() -> AnalysisResult {
    return provider.rx.request(.readAnalysis)
      .timeout(RxTimeInterval.seconds(2), scheduler: MainScheduler.instance)
      .filterSuccessfulStatusCodes()
      .map(Analysis.self)
      .map {
        if StorageManager.shared.updateAnalysis($0) { return .success($0) }
        return .error(.unknown)
      }
      .catchError { [unowned self] in
        self.catchMongliError($0)
          .map { result -> NetworkResultWithValue<Analysis> in
            switch result {
            case .success: return .error(.unknown)
            case .error(let err): return .error(err)
            }
        }
      }
  }
}
