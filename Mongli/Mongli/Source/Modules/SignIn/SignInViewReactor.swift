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
import RxFlow
import RxSwift

final class SignInViewReactor: Reactor, Stepper {

  enum Action {
    case signIn(ASAuthorization?)
  }

  enum Mutation {
    case setSignedIn
    case setError(LocalizedString)
  }

  struct State { }

  let initialState: State = .init()
  var steps: PublishRelay<Step> = .init()

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
            case .success: return .setSignedIn
            case .error(let error): return .setError(error.message)
            }
          }

      return result
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    switch mutation {
    case .setSignedIn: steps.accept(step: .userIsSignedIn)
    case .setError(let error): steps.accept(step: .toast(error))
    }
    return state
  }
}
