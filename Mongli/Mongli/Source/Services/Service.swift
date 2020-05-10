//
//  Service.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/18.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

import Moya
import RxFlow
import RxSwift

class Service: ServiceType {
  let provider = MoyaProvider<MongliAPI>()

  func signIn(_ uid: String, name: String?) -> BasicResult {
    return provider.rx.request(.signIn(uid, name: name))
      .timeout(RxTimeInterval.seconds(2), scheduler: MainScheduler.instance)
      .filterSuccessfulStatusCodes()
      .map(Token.self)
      .map { token -> NetworkResult in
        var user = User(uid: uid, name: "", token: token)

        if let name = name {
          user.name = name
        } else {
          guard let name = TokenManager.userName(token.refreshToken) else { return .error(.unknown) }
          user.name = name
        }

        if StorageManager.shared.readUser() != nil {
          if StorageManager.shared.updateUser(user) { return .success }
        }

        if StorageManager.shared.createUser(user) { return .success }
        return .error(.unknown)
      }
      .retryWhen {
        $0.flatMap { error -> Observable<Int> in
          return NetworkError(error) == .conflict
            ? Observable.error(error)
            : Observable<Int>.timer(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
        }
        .take(1)
      }
      .catchError { .just(.error(NetworkError($0) ?? .unknown)) }
  }

  func revokeToken() -> BasicResult {
    return provider.rx.request(.revokeToken)
      .timeout(RxTimeInterval.seconds(2), scheduler: MainScheduler.instance)
      .filterSuccessfulStatusCodes()
      .map { _ -> NetworkResult in
        if StorageManager.shared.deleteAll() { return .success }
        return .error(.unknown)
      }
      .retry(1)
      .catchError { .just(.error(NetworkError($0) ?? .unknown)) }
  }

  func catchMongliError(_ error: Error) -> BasicResult {
    guard let error = NetworkError(error) else { return .just(.error(.unknown)) }

    switch error {
    case .unauthorized:
      return self.renewalToken()

    default:
      return .just(.error(error))
    }
  }

  func checkToken() -> BasicResult? {
    if !TokenManager.accessTokenIsVaildate() {
      return self.renewalToken()
    }
    return nil
  }

  private func renewalToken() -> BasicResult {
    return provider.rx.request(.renewalToken)
      .timeout(RxTimeInterval.seconds(2), scheduler: MainScheduler.instance)
      .filterSuccessfulStatusCodes()
      .map(StringJSON.self)
      .map { json -> NetworkResult in
        guard let token = json["accessToken"],
           var user = StorageManager.shared.readUser() else { return .error(.unknown) }

        user.token.accessToken = token
        if StorageManager.shared.updateUser(user) { throw NetworkError.ok }
        return .error(.unknown)

      }
      .retryWhen {
        $0.flatMap { error -> Observable<Int> in
          return NetworkError(error) != .ok
            ? Observable.error(error)
            : Observable<Int>.timer(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance).take(1)
        }
      }
      .catchError { [unowned self] error -> BasicResult in
        guard let error = NetworkError(error) else { return .just(.error(.unknown)) }

        switch error {
        case .unauthorized:
          if let user = StorageManager.shared.readUser() {
            return self.signIn(user.uid, name: nil)
          }
          return self.forceLogout()

        case .notFound, .conflict:
          return self.forceLogout()

        default:
          return .just(.error(error))
        }
      }
  }

  private func forceLogout() -> BasicResult {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return .just(.error(.unknown)) }

    return self.revokeToken().do(onSuccess: { result in
        switch result {
        case .success: appDelegate.signInIsRequired()
        case .error(let err): throw err
        }
      })
      .catchError { .just(.error(NetworkError($0) ?? .unknown)) }
  }
}
