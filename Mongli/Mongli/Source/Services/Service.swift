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

  var currentUserInfo: UserInfo? {
    return DatabaseManager.read(.info) as? UserInfo
  }

  func signIn(_ uid: String, name: String?) -> BasicResult {
    return provider.rx.request(.signIn(uid, name: name))
      .filterSuccessfulStatusCodes()
      .map(Token.self)
      .map { [weak self] token -> NetworkResult in
        let userInfo = UserInfo()
        userInfo.uid = uid
        userInfo.token = token

        if let name = name {
          userInfo.name = name
        } else {
          userInfo.name = TokenManager.userName(token.accessToken)
        }

        if self?.currentUserInfo != nil {
          if DatabaseManager.update(.info, object: userInfo) { return .success }
        }

        if DatabaseManager.create(userInfo) { return .success }
        return .error(.unknown)
      }
      .retryWhen {
        $0.flatMap { error -> Observable<Int> in
          return NetworkError(error) == .conflict
            ? Observable.error(error)
            : Observable<Int>.timer(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance).take(1)
        }
      }
      .catchError { .just(.error(NetworkError($0) ?? .unknown)) }
  }

  func revokeToken() -> BasicResult {
    return provider.rx.request(.revokeToken)
      .filterSuccessfulStatusCodes()
      .map { _ -> NetworkResult in
        if DatabaseManager.deleteAll() { return .success }
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

  private func renewalToken() -> BasicResult {
    return provider.rx.request(.renewalToken)
      .filterSuccessfulStatusCodes()
      .map(StringJSON.self)
      .map { [weak self] json -> NetworkResult in
        guard let token = json["accessToken"],
          let self = self else { return .error(.unknown) }

        if let object = self.currentUserInfo {
          object.token?.accessToken = token
          if DatabaseManager.update(.info, object: object) { throw NetworkError.ok }
          return .error(.unknown)
        }
        return .error(.notFound)
      }
      .retryWhen {
        $0.flatMap { error -> Observable<Int> in
          return NetworkError(error) != .ok
            ? Observable.error(error)
            : Observable<Int>.timer(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance).take(1)
        }
      }
      .catchError { [weak self] error -> BasicResult in
        guard let error = NetworkError(error),
          let self = self else { return .just(.error(.unknown)) }

        switch error {
        case .unauthorized:
          if let info = self.currentUserInfo, let uid = info.uid {
            return self.signIn(uid, name: nil)
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
      case .success:
        if let flow = appDelegate.appFlow {
          return appDelegate.setupFlow(flow)
        }

      case .error(let err):
        throw err
      }
    })
    .catchError { .just(.error(NetworkError($0) ?? .unknown)) }
  }
}
