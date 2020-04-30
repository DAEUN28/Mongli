//
//  DreamService.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/19.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

import RxSwift

final class DreamService: Service, DreamServiceType {
  func createDream(_ dream: Dream) -> BasicResult {
    let request = provider.rx.request(.createDream(dream))
      .timeout(RxTimeInterval.seconds(2), scheduler: MainScheduler.instance)
      .filterSuccessfulStatusCodes()
      .map { _ in .success }
      .do(afterSuccess: { _ in RefreshCenter.shared.refreshAll() })
      .catchError { [unowned self] in self.catchMongliError($0) }

    if let checkToken = self.checkToken() {
      return checkToken.flatMap {
        switch $0 {
        case .success: return request
        case .error(let err): return .just(.error(err))
        }
      }
    }

    return request
  }

  func readDream(_ id: Int) -> DreamResult {
    let request = provider.rx.request(.readDream(id))
      .timeout(RxTimeInterval.seconds(2), scheduler: MainScheduler.instance)
      .filterSuccessfulStatusCodes()
      .map(Dream.self)
      .map { .success($0) }
      .catchError { [unowned self] in
        self.catchMongliError($0)
          .map { result -> NetworkResultWithValue<Dream> in
            switch result {
            case .success: return .error(.unknown)
            case .error(let err): return .error(err)
            }
        }
      }

    if let checkToken = self.checkToken() {
      return checkToken.flatMap {
        switch $0 {
        case .success: return request
        case .error(let err): return .just(.error(err))
        }
      }
    }

    return request
  }

  func updateDream(_ dream: Dream) -> BasicResult {
    let request = provider.rx.request(.updateDream(dream))
      .timeout(RxTimeInterval.seconds(2), scheduler: MainScheduler.instance)
      .filterSuccessfulStatusCodes()
      .map { _ in .success }
      .do(afterSuccess: { _ in RefreshCenter.shared.homeNeedRefresh.accept(true) })
      .catchError { [unowned self] in self.catchMongliError($0) }

    if let checkToken = self.checkToken() {
      return checkToken.flatMap {
        switch $0 {
        case .success: return request
        case .error(let err): return .just(.error(err))
        }
      }
    }

    return request
  }

  func deleteDream(_ id: Int) -> BasicResult {
    let request = provider.rx.request(.deleteDream(id))
      .timeout(RxTimeInterval.seconds(2), scheduler: MainScheduler.instance)
      .filterSuccessfulStatusCodes()
      .map { _ in .success }
      .do(afterSuccess: { _ in RefreshCenter.shared.refreshAll() })
      .catchError { [unowned self] in self.catchMongliError($0) }

    if let checkToken = self.checkToken() {
      return checkToken.flatMap {
        switch $0 {
        case .success: return request
        case .error(let err): return .just(.error(err))
        }
      }
    }

    return request
  }

  func readMonthlyDreams(_ month: String) -> MonthlyDreamsResult {
    let request = provider.rx.request(.readMonthlyDreams(month))
      .timeout(RxTimeInterval.seconds(2), scheduler: MainScheduler.instance)
      .filterSuccessfulStatusCodes()
      .map(MonthlyDreams.self)
      .map { .success($0) }
      .do(afterSuccess: { _ in RefreshCenter.shared.homeNeedRefresh.accept(false) })
      .catchError { [unowned self] in
        self.catchMongliError($0)
          .map { result -> NetworkResultWithValue<MonthlyDreams> in
            switch result {
            case .success: return .error(.unknown)
            case .error(let err): return .error(err)
            }
        }
      }

    if let checkToken = self.checkToken() {
      return checkToken.flatMap {
        switch $0 {
        case .success: return request
        case .error(let err): return .just(.error(err))
        }
      }
    }

    return request
  }

  func readDailyDreams(_ date: String) -> SummaryDreamsResult {
    let request = provider.rx.request(.readDailyDreams(date))
      .timeout(RxTimeInterval.seconds(2), scheduler: MainScheduler.instance)
      .filterSuccessfulStatusCodes()
      .map(SummaryDreams.self)
      .map { return .success($0) }
      .do(afterSuccess: { _ in RefreshCenter.shared.homeNeedRefresh.accept(false) })
      .catchError { [unowned self] in
        self.catchMongliError($0)
          .map { result -> NetworkResultWithValue<SummaryDreams> in
            switch result {
            case .success: return .error(.unknown)
            case .error(let err): return .error(err)
            }
        }
      }

    if let checkToken = self.checkToken() {
      return checkToken.flatMap {
        switch $0 {
        case .success: return request
        case .error(let err): return .just(.error(err))
        }
      }
    }

    return request
  }

  func deleteDailyDreams(_ date: String) -> BasicResult {
    let request = provider.rx.request(.deleteDailyDreams(date))
      .timeout(RxTimeInterval.seconds(2), scheduler: MainScheduler.instance)
      .filterSuccessfulStatusCodes()
      .map { _ in .success }
      .do(afterSuccess: { _ in RefreshCenter.shared.moreNeedRefresh.accept(true) })
      .catchError { [unowned self] in self.catchMongliError($0) }

    if let checkToken = self.checkToken() {
      return checkToken.flatMap {
        switch $0 {
        case .success: return request
        case .error(let err): return .just(.error(err))
        }
      }
    }

    return request
  }

  func searchDream(_ query: SearchQuery) -> SummaryDreamsResult {
    let request = provider.rx.request(.searchDream(query))
      .timeout(RxTimeInterval.seconds(2), scheduler: MainScheduler.instance)
      .filterSuccessfulStatusCodes()
      .map(SummaryDreams.self)
      .map { return .success($0) }
      .catchError { [unowned self] in
        self.catchMongliError($0)
          .map { result -> NetworkResultWithValue<SummaryDreams> in
            switch result {
            case .success: return .error(.unknown)
            case .error(let err): return .error(err)
            }
        }
      }

    if let checkToken = self.checkToken() {
      return checkToken.flatMap {
        switch $0 {
        case .success: return request
        case .error(let err): return .just(.error(err))
        }
      }
    }

    return request
  }
}
