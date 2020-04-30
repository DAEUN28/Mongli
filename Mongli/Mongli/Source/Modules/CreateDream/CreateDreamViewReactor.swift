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
import RxFlow
import RxSwift

final class CreateDreamViewReactor: Reactor, Stepper {

  enum Action {
    case createDream(Dream)
    case dateButtonDidTap
    case categoryInfoButtonDidTap
    case cancelWrite
  }

  enum Mutation {
    case setDate(Date)
    case setPopVC
    case setError(LocalizedString)
    case setLoading(Bool)
  }

  struct State {
    var date: Date = .init()
    var isLoading: Bool = false
  }

  let initialState: State = .init()
  var steps: PublishRelay<Step> = .init()

  private let service: DreamService

  init(_ service: DreamService) {
    self.service = service
  }

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .createDream(let dream):
      let startLoading: Observable<Mutation> = .just(.setLoading(true))
      let endLoading: Observable<Mutation> = .just(.setLoading(false))
      let result: Observable<Mutation> = service.createDream(dream)
        .asObservable()
        .map {
          switch $0 {
          case .success: return .setPopVC
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

    case .setPopVC:
      steps.accept(step: .popVC)

    case .setError(let error):
      steps.accept(step: .toast(error))

    case .setLoading(let isLoading):
      state.isLoading = isLoading
    }

    return state
  }
}
