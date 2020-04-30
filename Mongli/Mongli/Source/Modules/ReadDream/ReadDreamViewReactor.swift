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
import RxFlow
import RxSwift

final class ReadDreamViewReactor: Reactor, Stepper {

  enum Action {
    case categoryButtonDidTap
    case deleteButtonDidTap
    case updateButtonDidTap
  }

  enum Mutation {
    case setDream(Dream?)
    case setError(LocalizedString)
  }

  struct State {
    var dream: Dream?
  }

  let initialState: State = State()
  var steps: PublishRelay<Step> = .init()

  private let service: DreamService
  private let id: Int
  private let disposeBag: DisposeBag = . init()

  init(_ service: DreamService, id: Int) {
    self.service = service
    self.id = id
  }

  func transform(state: Observable<State>) -> Observable<State> {
    return state.flatMap { [weak self] state -> Observable<State> in
      guard let self = self, state.dream == nil else { return .just(state) }
      var state = state

      return self.service.readDream(self.id)
        .asObservable()
        .map {
          switch $0 {
          case .success(let dream): state.dream = dream
          case .error(let error): self.steps.accept(step: .toast(error.message))
          }
          return state
      }
    }
  }

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .categoryButtonDidTap:
      steps.accept(step: .categoryInfoIsRequired)
      return .empty()

    case .deleteButtonDidTap:
      guard let dream = self.currentState.dream, let id = dream.id else { return .empty() }

      steps.accept(step: .alert(.deleteDream(dream.title), handler: { [weak self] _ in
        guard let self = self else { return }

        self.service.deleteDream(id).asObservable()
          .bind {
            switch $0 {
            case .success: self.steps.accept(step: .popVC)
            case .error(let error): self.steps.accept(step: .toast(error.message))
            }
          }
          .disposed(by: self.disposeBag)
      }))

      return .empty()

    case .updateButtonDidTap:
      if let dream = currentState.dream {
        steps.accept(step: .updateDreamIsRequired(dream))
      }
      return .empty()
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case .setDream(let dream):
      state.dream = dream

    case .setError(let error):
      steps.accept(step: .toast(error))
    }
    return state
  }
}
