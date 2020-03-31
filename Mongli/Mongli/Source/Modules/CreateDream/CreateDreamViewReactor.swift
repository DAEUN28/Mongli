//
//  CreateDreamViewReactor.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/20.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

import ReactorKit
import RxCocoa
import RxSwift

final class CreateDreamViewReactor: Reactor {

  enum Action {
    case createDream(Dream)
  }

  enum Mutation {
    case setError(LocalizedString?)
    case setLoading(Bool)
  }

  struct State {
    var error: LocalizedString?
    var isLoading: Bool = false
  }

  let initialState: State = State()
  private let service: DreamService

  init(_ service: DreamService) {
    self.service = service
  }

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .createDream(let dream):
      let startLoading: Observable<Mutation> = .just(.setLoading(true))
      let result: Observable<Mutation> = self.service.createDream(dream)
        .asObservable()
        .map {
          switch $0 {
          case .success: return .setLoading(false)
          case .error(let error): return .setError(error.message)
          }
        }

      return .concat([startLoading, result])
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case .setError(let error):
      state.error = error
      return state

    case .setLoading(let isLoading):
      state.isLoading = isLoading
      return state
    }
  }
}
