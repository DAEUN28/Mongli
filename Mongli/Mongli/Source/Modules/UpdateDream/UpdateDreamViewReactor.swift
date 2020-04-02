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
import RxFlow
import RxSwift

final class UpdateDreamViewReactor: Reactor, Stepper {

  enum Action {
    case updateDream(Dream)
  }

  enum Mutation {
    case setLoading(Bool)
  }

  struct State {
    let existingDream: Dream
    var isLoading: Bool = false
  }

  var steps = PublishRelay<Step>()

  let initialState: State
  private let service: DreamService
  private let id: Int

  init(_ service: DreamService, dream: Dream) {
    self.service = service
    self.id = dream.id ?? 0

    self.initialState = State(existingDream: dream)
  }

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .updateDream(let dream):
      let startLoading: Observable<Mutation> = .just(.setLoading(true))
      let result: Observable<Mutation> = self.service.updateDream(dream)
        .delay(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
        .asObservable()
        .map { [weak self] in
          switch $0 {
          case .success:
            self?.steps.accept(MongliStep.updateDreamIsComplete(dream))
            return .setLoading(false)

          case .error(let err):
            self?.steps.accept(MongliStep.toast(err.message ?? LocalizedString.unknownErrorMsg))
            return .setLoading(true)
          }
        }

      return .concat([startLoading, result])
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case .setLoading(let isLoading):
      state.isLoading = isLoading
      return state
    }
  }
}
