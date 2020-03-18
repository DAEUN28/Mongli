//
//  Service.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/18.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

import Moya
import RxSwift

class Service: ServiceType {
  let provider = MoyaProvider<MongliAPI>()

  var currentUserInfo: UserInfo? {
    return DatabaseManager.read(.info) as? UserInfo
  }

  func signIn(_ uid: String, name: String?) -> BasicResult {
    return provider.rx.request(.signIn(uid, name: name))
      .asObservable()
      .filterSuccessfulStatusCodes()
      .map(Token.self)
      .map { token -> LocalizedString? in
        let userInfo = UserInfo()
        userInfo.uid = uid
        userInfo.token = token

        if let name = name {
          userInfo.name = name
        } else {
          userInfo.name = TokenManager.userName(token.accessToken)
        }

        if DatabaseManager.create(userInfo) { return nil }
        return .unknownErrorMsg
      }
      .catchError { error -> Observable<LocalizedString?> in
        guard let statusCode = StatusCode(error) else { return .just(.unknownErrorMsg) }

        switch statusCode {
        case .notFound:
          return .just(.notFoundUserErrorMsg)
        case .conflict:
          return .just(.userConflictErrorMsg)
        default:
          return .just(statusCode.message)
        }
      }
  }

  func revokeToken() -> BasicResult {
    return provider.rx.request(.revokeToken)
      .asObservable()
      .filterSuccessfulStatusCodes()
      .map { _ -> LocalizedString? in
        if DatabaseManager.deleteAll() { return nil }
        return .unknownErrorMsg
      }
      .catchErrorJustReturn(.retryMsg)
  }

  func catchMongliError(_ error: Error) -> BasicResult {
    guard let statusCode = StatusCode(error) else { return .just(.unknownErrorMsg) }

    switch statusCode {
    case .unauthorized:
      return renewalToken()
    default:
      return .just(statusCode.message)
    }
  }

  private func renewalToken() -> BasicResult {
    return provider.rx.request(.renewalToken)
      .asObservable()
      .filterSuccessfulStatusCodes()
      .mapJSON()
      .map { [weak self] json -> LocalizedString? in
        guard let json = json as? [String: String],
          let token = json["accessToken"],
          let self = self else { return .unknownErrorMsg }

        if let object = self.currentUserInfo {
          object.token?.accessToken = token
          if DatabaseManager.update(.info, object: object) { return nil }
          return .unknownErrorMsg
        }
        return .notFoundUserForcedLogoutMsg
      }
      .catchError { error -> Observable<LocalizedString?> in
        guard let statusCode = StatusCode(error) else { return .just(.unknownErrorMsg) }

        switch statusCode {
        case .unauthorized:
          if let info = DatabaseManager.read(.info) as? UserInfo, let uid = info.uid {
            return self.signIn(uid, name: nil)
          } else {
            return self.revokeToken()
          }
        case .notFound:
          return .just(.notFoundUserForcedLogoutMsg)
        case .conflict:
          return .just(.userConflictForcedLogoutMsg)
        default:
          return .just(statusCode.message)
        }
      }
  }
}
