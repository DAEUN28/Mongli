//
//  UpdateDreamViewReactor.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/04/02.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

import ReactorKit
import RxCocoa
import RxSwift

final class UpdateDreamViewReactor: Reactor {

  enum Action {
    case updateDream
  }

  enum Mutation {
    case setError(LocalizedString?)
    case setLoading(Bool)
  }

  struct State {
    var existingDream: Dream
    var error: LocalizedString?
    var isLoading: Bool = false
  }

  let initialState: State
  private let service: DreamService
  private let id: Int

  init(_ service: DreamService, dream: Dream) {
    self.service = service
    self.id = dream.id ?? 0

    self.initialState = State(existingDream: dream)
  }

  func mutate(action: Action) -> Observable<Mutation> {
    return .empty()
//    switch action {
//    case .deleteDream:
//      guard let id = self.currentState.dream?.id else { return .empty() }
//
//      let startLoading: Observable<Mutation> = .just(.setLoading(true))
//      let result: Observable<Mutation> = self.service.deleteDream(id)
//        .asObservable()
//        .map {
//          switch $0 {
//          case .success: return .setLoading(false)
//          case .error(let err): return .setError(err.message)
//          }
//        }
//
//      return .concat([startLoading, result])
//    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    return state
//    var state = state
//    switch mutation {
//    case .setError(let error):
//      state.error = error
//      return state
//
//    case .setLoading(let isLoading):
//      state.isLoading = isLoading
//      return state
//    }
  }
}
