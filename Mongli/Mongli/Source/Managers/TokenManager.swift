//
//  TokenManager.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/17.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

import SwiftJWT

struct TokenManager {
  struct TokenClaims: Claims {
    var exp: Date?
    var id: Int
    var name: String
  }

  enum TokenType {
    case access, refresh
  }

  private static let privateKey = try! Data(contentsOf: URL(fileURLWithPath: #file + "/privateKey"),
                                            options: .alwaysMapped)
  private static let jwtSigner = JWTSigner.hs256(key: privateKey)
  private static let jwtVerifier = JWTVerifier.hs256(key: privateKey)
  private static let jwtEncoder = JWTEncoder(jwtSigner: jwtSigner)
  private static let jwtDecoder = JWTDecoder(jwtVerifier: jwtVerifier)

  static var currentToken: Token? {
    return StorageManager.shared.readUser()?.token
  }

  static func userID() -> Int? {
    guard let token = currentToken?.accessToken else { return nil }
    return try? JWT<TokenClaims>(jwtString: token).claims.id
  }

  static func userName(_ token: String?) -> String? {
    guard let token = token else { return nil }
    return try? JWT<TokenClaims>(jwtString: token).claims.name
  }

  static func accessTokenIsVaildate() -> Bool {
    guard let token = currentToken?.accessToken else { return false }
    return isVaildate(token)
  }

  static func refreshTokenIsVaildate() -> Bool {
    guard let token = currentToken?.refreshToken else { return false }
    return isVaildate(token)
  }

  static private func isVaildate(_ token: String) -> Bool {
    if !JWT<TokenClaims>.verify(token, using: jwtVerifier) { return false }

    let result
      = try? JWT<TokenClaims>(jwtString: token, verifier: jwtVerifier).validateClaims() == .success
    return result ?? false
  }
}
