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
    var sub: Int
  }

  private let jwtSigner: JWTSigner
  private let jwtVerifier: JWTVerifier
  private let jwtEncoder: JWTEncoder
  private let jwtDecoder: JWTDecoder

  init() {
    let privateKey = try! Data(contentsOf: URL(fileURLWithPath: #file + "/privateKey"),
                               options: .alwaysMapped)
    jwtSigner = JWTSigner.hs256(key: privateKey)
    jwtVerifier = JWTVerifier.hs256(key: privateKey)
    jwtEncoder = JWTEncoder(jwtSigner: jwtSigner)
    jwtDecoder = JWTDecoder(jwtVerifier: jwtVerifier)
  }

  func toUserID(_ token: String) -> Int? {
    return try? JWT<TokenClaims>(jwtString: token).claims.sub
  }

  func isVaildate(_ token: String) -> Bool {
    if !JWT<TokenClaims>.verify(token, using: jwtVerifier) { return false }

    let result = try? JWT<TokenClaims>(jwtString: token, verifier: jwtVerifier).validateClaims() == .success
    return result ?? false
  }
}
