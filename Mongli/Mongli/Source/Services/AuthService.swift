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

  var userIsSignedIn: Observable<Bool> {
    return .just(StorageManager.shared.readUser() != nil)
  }

  func logout() -> BasicResult {
    let request = revokeToken()

    if let checkToken = self.checkToken() {
      return checkToken.flatMap {
        switch $0 {
        case .success: return request
        case .error(let err): return .just(.error(err))
        }
      }
    }

    return request
  }

  func deleteUser() -> BasicResult {
    let request = provider.rx.request(.deleteUser)
      .timeout(RxTimeInterval.seconds(2), scheduler: MainScheduler.instance)
      .filterSuccessfulStatusCodes()
      .map { _ -> NetworkResult in
        if StorageManager.shared.deleteAll() { return .success }
        return .error(.unknown)
      }
      .catchErrorJustReturn(.error(.unknown))

    if let checkToken = self.checkToken() {
      return checkToken.flatMap {
        switch $0 {
        case .success: return request
        case .error(let err): return .just(.error(err))
        }
      }
    }

    return request
  }

  func rename(_ name: String) -> BasicResult {
    let request = provider.rx.request(.rename(name))
      .timeout(RxTimeInterval.seconds(2), scheduler: MainScheduler.instance)
      .filterSuccessfulStatusCodes()
      .map { _ -> NetworkResult in
        if var user = StorageManager.shared.readUser() {
          user.name = name
          if StorageManager.shared.updateUser(user) { return .success }
          return .error(.unknown)
        }
        return .error(.notFound)
      }
      .catchError { [unowned self] in self.catchMongliError($0) }

    if let checkToken = self.checkToken() {
      return checkToken.flatMap {
        switch $0 {
        case .success: return request
        case .error(let err): return .just(.error(err))
        }
      }
    }

    return request
  }

  func readAnalysis() -> BasicResult {
    let request = provider.rx.request(.readAnalysis)
      .timeout(RxTimeInterval.seconds(2), scheduler: MainScheduler.instance)
      .filterSuccessfulStatusCodes()
      .map(Analysis.self)
      .map {
        if StorageManager.shared.readAnalysis() == nil {
          return StorageManager.shared.createAnalysis($0) ? .success : .error(.unknown)
        }
        if StorageManager.shared.updateAnalysis($0) { return .success }
        return .error(.unknown)
      }
      .catchError { [unowned self] in
        self.catchMongliError($0)
          .map { result -> NetworkResult in
            switch result {
            case .success: return .error(.unknown)
            case .error(let err): return .error(err)
            }
        }
      }

    if let checkToken = self.checkToken() {
      return checkToken.flatMap {
        switch $0 {
        case .success: return request
        case .error(let err): return .just(.error(err))
        }
      }
    }

    return request
  }
}
