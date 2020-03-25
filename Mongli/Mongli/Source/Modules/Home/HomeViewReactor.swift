//
//  HomeViewReactor.swift
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

final class HomeViewReactor: Reactor {

  enum Action {
    case selectDate(Date)
    case selectMonth(Date)
    case deleteAllDreams
    case selectDream(IndexPath)
  }

  enum Mutation {
    case setSelectedDate(Date)
    case setDailyDreams([SummaryDream])
    case setDailyDreamsEmpty(Bool)
    case setMonthlyDreams(MonthlyDreams)
    case setDeletedAllDreams(Bool)
    case setSelectedDreamID(Int)
    case setError(LocalizedString?)
    case setLoading(Bool)
  }

  struct State {
    var selectedDate: String = "yyyy-MM-dd"
    var dailyDreams: [SummaryDream] = [SummaryDream]()
    var dailyDreamsIsEmpty: Bool = false
    var monthlyDreams: MonthlyDreams = MonthlyDreams()
    var isDeletedAllDreams: Bool = false
    var selectedDreamID: Int?
    var error: LocalizedString?
    var isLoading: Bool = false
  }

  let initialState = State()
  private let service: DreamService

  init(_ service: DreamService) {
    self.service = service
  }

  func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
    return self.currentState.dailyDreams.isEmpty
      ? .merge([mutation, .just(.setDailyDreamsEmpty(true))])
      : .merge([mutation, .just(.setDailyDreamsEmpty(false))])
  }

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .selectDate(let date):
      if self.currentState.isLoading { return .empty() }
      let dateString = dateFormatter.string(from: date)

      let setSelectedDate: Observable<Mutation> = .just(.setSelectedDate(date))
      let result: Observable<Mutation>
        = self.service.readDailyDreams(dateString)
          .asObservable()
          .map {
            switch $0 {
            case .success(let summaryDreams): return .setDailyDreams(summaryDreams)
            case .error(let error):
              return error == .noContent ? .setDailyDreamsEmpty(true) : .setError(error.message)
            }
          }

      return .merge([setSelectedDate, result])

    case .selectMonth(let month):
      if self.currentState.isLoading { return .empty() }
      let monthString = dateFormatter.string(from: month)

      let result: Observable<Mutation> = self.service.readMonthlyDreams(monthString)
          .asObservable()
          .map {
            switch $0 {
            case .success(let monthlyDreams): return .setMonthlyDreams(monthlyDreams)
            case .error(let error): return .setError(error.message)
            }
          }

      return result

    case .deleteAllDreams:
      if self.currentState.isLoading { return .empty() }

      let startLoading = Observable<Mutation>.just(.setLoading(true))
      let endLoading = Observable<Mutation>.just(.setLoading(false))
      let result: Observable<Mutation> = self.service.deleteDailyDreams(self.currentState.selectedDate)
        .asObservable()
        .map {
          switch $0 {
          case .success: return .setDeletedAllDreams(true)
          case .error(let error): return .setError(error.message)
          }
        }

      return .concat([startLoading, result, endLoading])

    case .selectDream(let indexPath):
      if self.currentState.isLoading { return .empty() }
      let dreamID = self.currentState.dailyDreams[indexPath.row].id

      return .just(.setSelectedDreamID(dreamID))
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case .setSelectedDate(let date):
      state.selectedDate = dateFormatter.string(from: date)
      state.isDeletedAllDreams = false
      return state

    case .setDailyDreams(let dailyDreams):
      state.dailyDreams = dailyDreams
      return state

    case .setDailyDreamsEmpty(let isEmpty):
      state.dailyDreamsIsEmpty = isEmpty
      return state

    case .setMonthlyDreams(let monthlyDreams):
      state.monthlyDreams = monthlyDreams
      return state

    case .setDeletedAllDreams(let isDeletedAllDreams):
      state.isDeletedAllDreams = isDeletedAllDreams
      return state

    case .setSelectedDreamID(let dreamID):
      state.selectedDreamID = dreamID
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
