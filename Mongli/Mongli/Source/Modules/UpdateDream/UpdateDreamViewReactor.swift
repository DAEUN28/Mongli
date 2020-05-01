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
    case dateButtonDidTap
    case categoryInfoButtonDidTap
    case cancelWrite
  }

  enum Mutation {
    case setDate(Date)
    case setUpdateDreamIsComplete(Dream)
    case setError(LocalizedString)
    case setLoading(Bool)
  }

  struct State {
    let existingDream: Dream
    var date: Date = .init()
    var isLoading: Bool = false
  }

  let initialState: State
  var steps: PublishRelay<Step> = .init()

  private let service: DreamService
  private let id: Int

  init(_ service: DreamService, dream: Dream) {
    self.service = service
    self.id = dream.id ?? 0

    self.initialState = .init(existingDream: dream)
  }

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .updateDream(let dream):
      let startLoading: Observable<Mutation> = .just(.setLoading(true))
      let endLoading: Observable<Mutation> = .just(.setLoading(false))
      let result: Observable<Mutation> = service.updateDream(dream)
        .delay(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
        .asObservable()
        .map {
          switch $0 {
          case .success: return .setUpdateDreamIsComplete(dream)
          case .error(let error): return .setError(error.message)
          }
      }

      return .concat([startLoading, result, endLoading])

    case .dateButtonDidTap:
      let date = PublishRelay<Mutation>()
      steps.accept(step: .datePickerActionSheet({ date.accept(.setDate($0)) }))
      return date.asObservable()

    case .categoryInfoButtonDidTap:
      steps.accept(step: .categoryInfoIsRequired)
      return .empty()

    case .cancelWrite:
      steps.accept(step: .alert(.cancelWrite, handler: nil))
      return .empty()
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case .setDate(let date):
      state.date = date

    case .setUpdateDreamIsComplete(let dream):
      steps.accept(step: .updateDreamIsComplete(dream))

    case .setError(let error):
      steps.accept(step: .toast(error))

    case .setLoading(let isLoading):
      state.isLoading = isLoading
    }

    return state
  }
}
