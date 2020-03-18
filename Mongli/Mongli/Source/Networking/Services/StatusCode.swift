//
//  StatusCode.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/18.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

import Moya

enum StatusCode: Int {
  case failure = 0
  case ok = 200
  case created = 201
  case noContent = 204
  case badRequest = 400
  case unauthorized = 401
  case notFound = 404
  case conflict = 409
  case serverError = 500

  init?(_ error: Error) {
    guard let error = error as? MoyaError,
      let response = error.response?.statusCode,
      let statusCode = StatusCode(rawValue: response) else { return nil }
    self = statusCode
  }

  func toString() -> String? {
    switch self {
    case .ok, .created, .noContent: return nil
    case .badRequest: return "잘못된 요청입니다"
    case .unauthorized: return "인증되지 않은 토큰 또는 만료된 토큰입니다"
    case .notFound: return "찾을 수 없는 사용자 또는 정보입니다"
    case .serverError: return "서버오류입니다"
    default: return "알 수 없는 오류입니다"
    }
  }
}
