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

final class HomeViewReactor: Reactor, Stepper {

  enum Action {
    case selectDate(Date)
    case selectMonth(Date)
    case deleteAllDreams
    case selectDream(IndexPath)
  }

  enum Mutation {
    case setSelectedDate(Date)
    case setDailyDreams([SummaryDream])
    case setMonthlyDreams(MonthlyDreams)
    case setDeleteIsSuccess(Bool)
    case setSelectedDreamID(Int)
    case setError(LocalizedString?)
    case setLoading(Bool)
  }

  struct State {
    var selectedDate: Date = Date()
    var dailyDreams: [SummaryDream] = [SummaryDream]()
    var monthlyDreams: MonthlyDreams = MonthlyDreams()
    var isLoading: Bool = false
  }

  let initialState = State()
  private let service: DreamService

  var steps = PublishRelay<Step>()

  init(_ service: DreamService) {
    self.service = service
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
            case .success(let summaryDreams): return .setDailyDreams(summaryDreams.dreams)
            case .error(let error):
              return error == .noContent ? .setDailyDreams([]) : .setError(error.message)
            }
          }

      return .merge([setSelectedDate, result])

    case .selectMonth(let month):
      if self.currentState.isLoading { return .empty() }
      let monthString: String = {
        var arr = dateFormatter.string(from: month).components(separatedBy: "-")
        arr.removeLast()
        return arr.joined(separator: "-")
      }()

      let result: Observable<Mutation> = self.service.readMonthlyDreams(monthString)
        .asObservable()
        .map {
          switch $0 {
          case .success(let monthlyDreams): return .setMonthlyDreams(monthlyDreams)
          case .error(let error):
            return error == .noContent ? .setMonthlyDreams([:]) : .setError(error.message)
          }
        }

      return result

    case .deleteAllDreams:
      if self.currentState.isLoading { return .empty() }
      let dateString = dateFormatter.string(from: self.currentState.selectedDate)

      let startLoading: Observable<Mutation> = .just(.setLoading(true))
      let endLoading: Observable<Mutation> = .just(.setLoading(false))
      let result: Observable<Mutation> = self.service.deleteDailyDreams(dateString)
        .asObservable()
        .map {
          switch $0 {
          case .success: return .setDeleteIsSuccess(true)
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
      state.selectedDate = date

    case .setDailyDreams(let dailyDreams):
      state.dailyDreams = dailyDreams

    case .setMonthlyDreams(let monthlyDreams):
      state.monthlyDreams = monthlyDreams

    case .setDeleteIsSuccess(let isSuccess):
      if !isSuccess { return state }
      self.steps.accept(MongliStep.toast(.deletedMsg))

    case .setSelectedDreamID(let dreamID):
      self.steps.accept(MongliStep.readDreamIsRequired(dreamID))

    case .setError(let error):
      guard let error = error else { return state }
      self.steps.accept(MongliStep.toast(error))

    case .setLoading(let isLoading):
      state.isLoading = isLoading
    }

    return state
  }
}
