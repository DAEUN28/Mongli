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
    case selectDream(IndexPath)
    case deleteAllDreamsButtonDidTap(Date)
    case createDreamButtonDidTap
  }

  enum Mutation {
    case setDailyDreams([SummaryDream])
    case setMonthlyDreams(MonthlyDreams)
    case setDeleted(String)
    case setSelectedDreamID(Int)
    case setError(LocalizedString)
    case setLoading(Bool)
  }

  struct State {
    var dailyDreams: [SummaryDream] = .init()
    var monthlyDreams: MonthlyDreams = .init()
    var isLoading: Bool = false
  }

  let initialState: State = .init()
  var steps: PublishRelay<Step> = .init()

  private let disposeBag: DisposeBag = .init()
  private let service: DreamService

  init(_ service: DreamService) {
    self.service = service
  }

  // swiftlint:disable function_body_length cyclomatic_complexity
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .selectDate(let date):
      let dateString = dateFormatter.string(from: date)

      let startLoading: Observable<Mutation> = .just(.setLoading(true))
      let endLoading: Observable<Mutation> = .just(.setLoading(false))
      let result: Observable<Mutation> = service.readDailyDreams(dateString).asObservable()
        .map {
          switch $0 {
          case .success(let summaryDreams): return .setDailyDreams(summaryDreams.dreams)
          case .error(let error):
            return error == .noContent ? .setDailyDreams([]) : .setError(error.message)
          }
      }

      return .concat([startLoading, result, endLoading])

    case .selectMonth(let month):
      let monthString: String = {
        var arr = dateFormatter.string(from: month).components(separatedBy: "-")
        arr.removeLast()
        return arr.joined(separator: "-")
      }()

      let startLoading: Observable<Mutation> = .just(.setLoading(true))
      let endLoading: Observable<Mutation> = .just(.setLoading(false))
      let result: Observable<Mutation> = service.readMonthlyDreams(monthString)
        .asObservable()
        .map {
          switch $0 {
          case .success(let monthlyDreams): return .setMonthlyDreams(monthlyDreams)
          case .error(let error):
            return error == .noContent ? .setMonthlyDreams([:]) : .setError(error.message)
          }
      }

      return .concat([startLoading, result, endLoading])

    case .selectDream(let indexPath):
      if currentState.isLoading { return .empty() }
      let dreamID = currentState.dailyDreams[indexPath.row].id

      return .just(.setSelectedDreamID(dreamID))

    case .deleteAllDreamsButtonDidTap(let date):
      if currentState.isLoading { return .empty() }
      let result = PublishRelay<Mutation>()

      steps.accept(step: .alert(.deleteDreams(date), handler: { [weak self] _ in
        guard let self = self else { return }
        let dateString = dateFormatter.string(from: date)

        result.accept(.setLoading(true))
        self.service.deleteDailyDreams(dateString).asObservable()
          .map {
            switch $0 {
            case .success: return .setDeleted(dateString)
            case .error(let error): return .setError(error.message)
            }
        }
        .do(afterNext: { _ in result.accept(.setLoading(false)) })
        .bind(to: result)
        .disposed(by: self.disposeBag)
      }))

      return result.asObservable()

    case .createDreamButtonDidTap:
      steps.accept(step: .createDreamIsRequired)
      return .empty()
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case .setDailyDreams(let dailyDreams):
      state.dailyDreams = dailyDreams

    case .setMonthlyDreams(let monthlyDreams):
      state.monthlyDreams = monthlyDreams

    case .setDeleted(let date):
      steps.accept(step: .toast(.deletedMsg))
      state.dailyDreams = []
      state.monthlyDreams.removeValue(forKey: date)

    case .setSelectedDreamID(let dreamID):
      steps.accept(step: .readDreamIsRequired(dreamID))

    case .setError(let error):
      steps.accept(step: .toast(error))

    case .setLoading(let isLoading):
      state.isLoading = isLoading
    }

    return state
  }
}
