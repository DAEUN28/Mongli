//
//  SearchViewReactor.swift
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

final class SearchViewReactor: Reactor, Stepper {

  enum Action {
    case search(String?)
    case selectDream(IndexPath)
    case refresh
    case loadMore
    case filterButtonDidTap
    case createButtonDidTap
  }

  enum Mutation {
    case setDreams(SummaryDreams?)
    case appendDreams([SummaryDream])
    case setSearchBarEnabled(Bool)
    case setRefreshing(Bool)
    case setError(LocalizedString)
    case setLoading(Bool)
  }

  struct State {
    var total: Int = 0
    var dreams: [SummaryDream] = .init()
    var searchBarIsEnabled: Bool = true
    var isRefreshing: Bool = false
    var isLoading: Bool = false
  }

  let searchQuery: BehaviorRelay<SearchQuery> = .init(value: .init())
  let initialState: State = .init()
  var steps: PublishRelay<Step> = .init()

  private let service: DreamService

  init(_ service: DreamService) {
    self.service = service
  }

  func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
    let setSearchBarEnabled: Observable<Mutation> = searchQuery.distinctUntilChanged()
      .map { $0.criteria != 2 }
      .map { .setSearchBarEnabled($0) }

    return .merge([mutation, setSearchBarEnabled])
  }

  // swiftlint:disable function_body_length cyclomatic_complexity
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .search(let keyword):
      if currentState.isLoading || currentState.isRefreshing { return .empty() }
      var query = searchQuery.value
      query.page = 0
      query.keyword = keyword

      let startLoading: Observable<Mutation> = .just(.setLoading(true))
      let endLoading: Observable<Mutation> = .just(.setLoading(false))
      let setDreams: Observable<Mutation> = service.searchDream(query).asObservable()
        .map {
          switch $0 {
          case .success(let summaryDreams): return .setDreams(summaryDreams)
          case .error(let error):
            return error == .noContent ? .setDreams(nil) : .setError(error.message)
          }
      }
      .do(afterNext: { [weak self] _ in
        self?.searchQuery.accept(query)
      })

      return .concat([startLoading, setDreams, endLoading])

    case .selectDream(let indexPath):
      let dreamID = currentState.dreams[indexPath.row].id
      steps.accept(step: .readDreamIsRequired(dreamID))

      return .empty()

    case .refresh:
      if currentState.isLoading || currentState.isRefreshing { return .empty() }
      if searchQuery.value.criteria != 2 && searchQuery.value.keyword == nil { return .empty() }
      var query = searchQuery.value
      query.page = 0

      let startRefreshing: Observable<Mutation> = .just(.setRefreshing(true))
      let endRefreshing: Observable<Mutation> = .just(.setRefreshing(false))
      let setDreams: Observable<Mutation> = service.searchDream(query).asObservable()
        .map {
          switch $0 {
          case .success(let summaryDreams): return .setDreams(summaryDreams)
          case .error(let error):
            return error == .noContent ? .setDreams(nil) : .setError(error.message)
          }
      }
      .do(afterNext: { [weak self] _ in
        self?.searchQuery.accept(query)
      })

      return .concat([startRefreshing, setDreams, endRefreshing])

    case .loadMore:
      if currentState.isLoading || currentState.isRefreshing { return .empty() }
      if currentState.dreams.count == currentState.total { return .empty() }

      var query = searchQuery.value
      query.page += 1
      searchQuery.accept(query)

      let startLoading: Observable<Mutation> = .just(.setLoading(true))
      let endLoading: Observable<Mutation> = .just(.setLoading(false))
      let appendDreams: Observable<Mutation> = service.searchDream(query).asObservable()
        .map {
          switch $0 {
          case .success(let summaryDreams): return .appendDreams(summaryDreams.dreams)
          case .error(let error):
            return error == .noContent ? .setDreams(nil) : .setError(error.message)
          }
      }
      .do(afterNext: { [weak self] _ in
        self?.searchQuery.accept(query)
      })

      return .concat([startLoading, appendDreams, endLoading])

    case .filterButtonDidTap:
      steps.accept(step: .filterIsRequired(searchQuery.value))
      return .empty()

    case .createButtonDidTap:
      steps.accept(step: .createDreamIsRequired)
      return .empty()
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case .setDreams(let dreams):
      state.total = dreams?.total ?? 0
      state.dreams = dreams?.dreams ?? []

    case .appendDreams(let dreams):
      state.dreams.append(contentsOf: dreams)

    case .setSearchBarEnabled(let isEnabled):
      state.searchBarIsEnabled = isEnabled

    case .setRefreshing(let isRefreshing):
      state.isRefreshing = isRefreshing

    case .setLoading(let isLoading):
      state.isLoading = isLoading

    case .setError(let error):
      steps.accept(step: .toast(error))
    }

    return state
  }
}
