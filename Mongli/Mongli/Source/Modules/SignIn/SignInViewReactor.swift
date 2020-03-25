//
//  SignInViewReactor.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/20.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import AuthenticationServices

import ReactorKit
import RxCocoa
import RxSwift

final class SignInViewReactor: Reactor {

  enum Action {
    case signIn(ASAuthorization?)
  }

  enum Mutation {
    case setSignedIn(Bool)
    case setError(LocalizedString?)
  }

  struct State {
    var isSignedIn: Bool = false
    var error: LocalizedString?
  }

  let initialState: State = State()
  private let service: AuthService

  init(_ service: AuthService) {
    self.service = service
  }

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .signIn(let authorization):
      guard let credential = authorization?.credential as? ASAuthorizationAppleIDCredential else {
        return .just(.setError(.notFoundUserErrorMsg))
      }

      let result: Observable<Mutation>
        = self.service.signIn(credential.user, name: credential.fullName?.givenName)
          .asObservable()
          .map {
            switch $0 {
            case .success: return .setSignedIn(true)
            case .error(let error): return .setError(error.message)
            }
          }

      return result
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case .setSignedIn(let isSignedIn):
      state.isSignedIn = isSignedIn
      return state

    case .setError(let error):
      state.error = error
      return state
    }
  }
}
