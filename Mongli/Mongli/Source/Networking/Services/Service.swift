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

  func signIn(_ uid: String, name: String?) -> Observable<String?> {
    return provider.rx.request(.signIn(uid, name: name))
      .asObservable()
      .filterSuccessfulStatusCodes()
      .map(Token.self)
      .map { token -> String? in
        let userInfo = UserInfo()
        userInfo.uid = uid
        userInfo.token = token

        if let name = name {
          userInfo.name = name
        } else {
          userInfo.name = TokenManager.userName(token.accessToken)
        }

        if DatabaseManager.create(userInfo) { return nil }
        return "알 수 없는 오류가 발생했습니다"
      }
      .catchError { error -> Observable<String?> in
        guard let statusCode = StatusCode(error) else { return .just("알 수 없는 오류가 발생했습니다") }

        switch statusCode {
        case .notFound:
          return .just("존재하지 않는 사용자입니다.\n설정에서 애플로그인 사용중지를 활성화고 앱을 다시 시작해주세요")
        case .conflict:
          return .just("이미 로그인된 사용자가 존재합니다")
        default:
          return .just(statusCode.toString())
        }
      }
  }

  func revokeToken() -> Observable<String?> {
    return provider.rx.request(.revokeToken)
      .asObservable()
      .filterSuccessfulStatusCodes()
      .map { _ -> String? in
        if DatabaseManager.deleteAll() { return nil }
        return "알 수 없는 오류가 발생했습니다"
      }
      .catchError { self.catchMongliError($0) }
  }

  func catchMongliError(_ error: Error) -> Observable<String?> {
    guard let statusCode = StatusCode(error) else { return .just("알 수 없는 오류가 발생했습니다") }

    switch statusCode {
    case .unauthorized:
      return renewalToken()
    default:
      return .just(statusCode.toString())
    }
  }

  private func renewalToken() -> Observable<String?> {
    return provider.rx.request(.renewalToken)
      .asObservable()
      .filterSuccessfulStatusCodes()
      .mapJSON()
      .map { [weak self] json -> String? in
        guard let json = json as? [String: String],
          let token = json["accessToken"] else { return "알 수 없는 오류가 발생했습니다" }

        if let object = self?.currentUserInfo {
          object.token?.accessToken = token
          if DatabaseManager.update(.info, object: object) { return nil }
          return "알 수 없는 오류가 발생했습니다"
        }
        return "현재 사용자 정보가 존재하지 않습니다."
      }
      .catchError { error -> Observable<String?> in
        guard let statusCode = StatusCode(error) else { return .just("알 수 없는 오류가 발생했습니다") }

        switch statusCode {
        case .unauthorized:
          if let info = DatabaseManager.read(.info) as? UserInfo, let uid = info.uid {
            return self.signIn(uid, name: nil)
          } else {
            /// route to SignInViewController
          }
        case .notFound:
          /// route to SignInViewController
          return .just("사용자정보를 찾을 수 없어 강제 로그아웃됩니다.")
        case .conflict:
          /// route to SignInViewController
          return .just("다른 사용자가 로그인되어있어 강제 로그아웃됩니다.")
        default: break
        }

        return .just(statusCode.toString())
      }
  }
}
