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
    return provider.rx.request(.createDream(dream))
      .filterSuccessfulStatusCodes()
      .map { _ in .success }
      .catchError { [unowned self] in self.catchMongliError($0) }
  }

  func readDream(_ id: Int) -> DreamResult {
    return provider.rx.request(.readDream(id))
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
  }

  func updateDream(_ dream: Dream) -> BasicResult {
    return provider.rx.request(.updateDream(dream))
      .filterSuccessfulStatusCodes()
      .map { _ in .success }
      .catchError { [unowned self] in self.catchMongliError($0) }
  }

  func deleteDream(_ id: Int) -> BasicResult {
    return provider.rx.request(.deleteDream(id))
      .filterSuccessfulStatusCodes()
      .map { _ in .success }
      .catchError { [unowned self] in self.catchMongliError($0) }
  }

  func readMonthlyDreams(_ month: String) -> MonthlyDreamsResult {
    return provider.rx.request(.readMonthlyDreams(month))
      .filterSuccessfulStatusCodes()
      .map(MonthlyDreams.self)
      .map { .success($0) }
      .catchError { [unowned self] in
        self.catchMongliError($0)
          .map { result -> NetworkResultWithValue<MonthlyDreams> in
            switch result {
            case .success: return .error(.unknown)
            case .error(let err): return .error(err)
            }
        }
      }
  }

  func readDailyDreams(_ date: String) -> SummaryDreamsResult {
    return provider.rx.request(.readDailyDreams(date))
      .filterSuccessfulStatusCodes()
      .map(SummaryDreamsJSON.self)
      .map { json -> NetworkResultWithValue<[SummaryDream]> in
        guard let dreams = json["dreams"] else { return .error(.unknown) }
        return .success(dreams)
      }
      .catchError { [unowned self] in
        self.catchMongliError($0)
          .map { result -> NetworkResultWithValue<[SummaryDream]> in
            switch result {
            case .success: return .error(.unknown)
            case .error(let err): return .error(err)
            }
        }
      }
  }

  func deleteDailyDreams(_ date: String) -> BasicResult {
    return provider.rx.request(.deleteDailyDreams(date))
      .filterSuccessfulStatusCodes()
      .map { _ in .success }
      .catchError { [unowned self] in self.catchMongliError($0) }
  }

  func searchDream(_ query: SearchQuery) -> SummaryDreamsResult {
    return provider.rx.request(.searchDream(query))
      .filterSuccessfulStatusCodes()
      .map(SummaryDreamsJSON.self)
      .map { json -> NetworkResultWithValue<[SummaryDream]> in
        guard let dreams = json["dreams"] else { return .error(.unknown) }
        return .success(dreams)
      }
      .catchError { [unowned self] in
        self.catchMongliError($0)
          .map { result -> NetworkResultWithValue<[SummaryDream]> in
            switch result {
            case .success: return .error(.unknown)
            case .error(let err): return .error(err)
            }
        }
      }
  }
}
