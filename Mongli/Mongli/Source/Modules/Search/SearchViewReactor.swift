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
    case searchBarIsEnabled(Bool)
    case refresh
    case loadMore
    case presentFilter
    case navigateToCreateDream
  }

  enum Mutation {
    case setDreams(SummaryDreams?)
    case appendDreams([SummaryDream])
    case setSearchBarEnabled(Bool)
    case setRefreshing(Bool)
    case setLoading(Bool)
    case setError(LocalizedString?)
  }

  struct State {
    var total: Int = 0
    var dreams: [SummaryDream] = []
    var searchBarIsEnabled: Bool = true
    var isRefreshing: Bool = false
    var isLoading: Bool = false
  }

  let searchQuery = BehaviorRelay<SearchQuery>(value: SearchQuery())
  let initialState = State()
  private let service: DreamService

  var steps = PublishRelay<Step>()

  init(_ service: DreamService) {
    self.service = service
  }

  func transform(action: Observable<Action>) -> Observable<Action> {
    let keywordIsEnabled: Observable<Action> = self.searchQuery
      .flatMap {
        $0.criteria == 2
          ? Observable.of(.searchBarIsEnabled(false), .search(nil))
          : Observable.just(.searchBarIsEnabled(true))
      }

    return .merge(action, keywordIsEnabled)
  }

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .search(let keyword):
      if self.currentState.isLoading || self.currentState.isRefreshing { return .empty() }
      var query = self.searchQuery.value
      query.page = 0
      query.keyword = keyword
      self.searchQuery.accept(query)

      let startLoading: Observable<Mutation> = .just(.setLoading(true))
      let endLoading: Observable<Mutation> = .just(.setLoading(false))
      let setDreams: Observable<Mutation> = self.service.searchDream(query).asObservable()
        .map {
          switch $0 {
          case .success(let summaryDreams): return .setDreams(summaryDreams)
          case .error(let error):
            return error == .noContent ? .setDreams(nil) : .setError(error.message)
          }
      }

      return .concat([startLoading, setDreams, endLoading])

    case .selectDream(let indexPath):
      let dreamID = self.currentState.dreams[indexPath.row].id
      self.steps.accept(MongliStep.readDreamIsRequired(dreamID))

      return .empty()

    case .searchBarIsEnabled(let isEnabled):
      return .just(.setSearchBarEnabled(isEnabled))

    case .refresh:
      if self.currentState.isLoading || self.currentState.isRefreshing { return .empty() }
      var query = self.searchQuery.value
      query.page = 0
      self.searchQuery.accept(query)

      let startRefreshing: Observable<Mutation> = .just(.setRefreshing(true))
      let endRefreshing: Observable<Mutation> = .just(.setRefreshing(false))
      let setDreams: Observable<Mutation> = self.service.searchDream(query).asObservable()
        .map {
          switch $0 {
          case .success(let summaryDreams): return .setDreams(summaryDreams)
          case .error(let error):
            return error == .noContent ? .setDreams(nil) : .setError(error.message)
          }
      }

      return .concat([startRefreshing, setDreams, endRefreshing])

    case .loadMore:
      if self.currentState.isLoading || self.currentState.isRefreshing { return .empty() }
      if self.currentState.dreams.count == self.currentState.total { return .empty() }

      var query = self.searchQuery.value
      query.page += 1
      self.searchQuery.accept(query)

      let startLoading: Observable<Mutation> = .just(.setLoading(true))
      let endLoading: Observable<Mutation> = .just(.setLoading(false))
      let appendDreams: Observable<Mutation> = self.service.searchDream(query).asObservable()
        .map {
          switch $0 {
          case .success(let summaryDreams): return .setDreams(summaryDreams)
          case .error(let error):
            return error == .noContent ? .setDreams(nil) : .setError(error.message)
          }
      }

      return .concat([startLoading, appendDreams, endLoading])

    case .presentFilter:
      self.steps.accept(MongliStep.filterIsRequired(self.searchQuery.value))
      return .empty()

    case .navigateToCreateDream:
      self.steps.accept(MongliStep.createDreamIsRequired)
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
      guard let error = error else { return state }
      self.steps.accept(MongliStep.toast(error))
    }

    return state
  }
}
