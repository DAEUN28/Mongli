//
//  MongliAPI.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/17.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

import Moya

enum MongliAPI {
  // Auth API
  case signIn(_ uid: String, name: String?)
  case renewalToken
  case revokeToken
  case rename(_ name: String)
  case deleteUser
  case readAnalysis

  // Dream API
  case createDream(_ dream: Dream)
  case readDream(_ id: Int)
  case updateDream(_ dream: Dream)
  case deleteDream(_ id: Int)
  case readMonthlyDreams(_ month: String)
  case readDailyDreams(_ date: String)
  case deleteDailyDreams(_ date: String)
  case searchDream(_ query: DreamQuery)
}

extension MongliAPI: TargetType {
  // MARK: baseURL
  var baseURL: URL {
    return URL(string: "http://127.0.0.1:2525/api")!
  }

  // MARK: path
  var path: String {
    switch self {
    case .signIn,
         .rename,
         .deleteUser,
         .readAnalysis:
      return "/auth"

    case .renewalToken,
         .revokeToken:
      return "/auth/token"

    case .createDream,
         .updateDream:
      return "/dream"

    case .readDream(let id),
         .deleteDream(let id):
      return "/dream/\(id)"

    case .readMonthlyDreams(let month):
      return "/calendar/" + month

    case .readDailyDreams(let date),
         .deleteDailyDreams(let date):
      return "/dreams/" + date

    case .searchDream:
      return "/search"
    }
  }

  // MARK: method
  var method: Moya.Method {
    switch self {
    case .signIn,
         .createDream:
      return .post

    case .renewalToken,
         .readAnalysis,
         .readDream,
         .readMonthlyDreams,
         .readDailyDreams,
         .searchDream:
      return .get

    case .rename:
      return .patch

    case .updateDream:
      return .put

    case .revokeToken,
         .deleteUser,
         .deleteDream,
         .deleteDailyDreams:
      return .delete
    }
  }

  // MARK: headers
  var headers: [String: String]? {
    switch self {
    case .signIn:
      return nil

    case .renewalToken:
      guard let token = TokenManager.currentToken?.refreshToken else { return nil }
      return ["Authorization": "Bearer" + token]

    default:
      guard let token = TokenManager.currentToken?.accessToken else { return nil }
     return ["Authorization": "Bearer" + token]
    }
  }

  // MARK: task
  var task: Task {
    switch self {
    case .signIn(let uid, let name):
      return .requestParameters(parameters: ["uid": uid, "name": name as Any],
                                encoding: JSONEncoding.default)

    case .rename(let name):
      return .requestParameters(parameters: ["name": name],
                                encoding: JSONEncoding.default)

    case .createDream(let dream),
         .updateDream(let dream):
      return .requestJSONEncodable(dream)

    case .searchDream(let query):
      guard let data = try? JSONEncoder().encode(query),
        let parameters = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
          return .requestPlain
      }
      return .requestParameters(parameters: parameters,
                                encoding: URLEncoding.queryString)

    default:
      return .requestPlain
    }
  }

  // MARK: sampleData
  var sampleData: Data {
    return Data()
  }
}
