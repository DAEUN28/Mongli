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

  var message: LocalizedString? {
    switch self {
    case .ok, .created, .noContent: return nil
    case .badRequest: return .badRequestErrorMsg
    case .unauthorized: return .unauthorizedErrorMsg
    case .notFound: return .notFoundErrorMsg
    case .serverError: return .serverErrorMsg
    default: return .unknownErrorMsg
    }
  }
}
