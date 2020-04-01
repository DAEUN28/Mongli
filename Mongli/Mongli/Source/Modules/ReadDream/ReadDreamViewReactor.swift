//
//  ReadDreamViewReactor.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/20.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

import ReactorKit
import RxCocoa
import RxSwift

final class ReadDreamViewReactor: Reactor {

  enum Action {
    case deleteDream
  }

  enum Mutation {
    case setDream(Dream?)
    case setError(LocalizedString?)
    case setLoading(Bool)
  }

  struct State {
    var dream: Dream?
    var error: LocalizedString?
    var isLoading: Bool = false
  }

  let initialState: State = State()
  private let service: DreamService
  private let id: Int

  init(_ service: DreamService, id: Int) {
    self.service = service
    self.id = id
  }

  func transform(state: Observable<State>) -> Observable<State> {
    return state.flatMap { [weak self] state -> Observable<State> in
      guard let self = self, state.dream == nil else { return .just(state) }
      var state = state

      return self.service.readDream(self.id).debug()
        .asObservable()
        .map {
          switch $0 {
          case .success(let dream):
            state.dream = dream
            return state

          case .error(let err):
            state.error = err.message
            return state
          }
      }
    }
  }

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .deleteDream:
      guard let id = self.currentState.dream?.id else { return .empty() }

      let startLoading: Observable<Mutation> = .just(.setLoading(true))
      let result: Observable<Mutation> = self.service.deleteDream(id)
        .asObservable()
        .map {
          switch $0 {
          case .success: return .setLoading(false)
          case .error(let err): return .setError(err.message)
          }
        }

      return .concat([startLoading, result])
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case .setDream(let dream):
      state.dream = dream
      return state

    case .setError(let error):
      state.error = error
      return state

    case .setLoading(let isLoading):
      state.isLoading = isLoading
      return state
    }
  }
}
