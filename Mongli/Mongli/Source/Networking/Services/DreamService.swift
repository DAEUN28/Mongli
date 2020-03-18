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
      .asObservable()
      .filterSuccessfulStatusCodes()
      .map { _ in nil }
      .catchError { [unowned self] in self.catchMongliError($0) }
  }

  func readDream(_ id: Int) -> DreamResult {
    return provider.rx.request(.readDream(id))
      .asObservable()
      .filterSuccessfulStatusCodes()
      .map(Dream.self)
      .map { ($0, nil) }
      .catchError { [unowned self] in self.catchMongliError($0).map { (nil, $0) } }
  }

  func updateDream(_ dream: Dream) -> BasicResult {
    return provider.rx.request(.updateDream(dream))
      .asObservable()
      .filterSuccessfulStatusCodes()
      .map { _ in nil }
      .catchError { [unowned self] in self.catchMongliError($0) }
  }

  func deleteDream(_ id: Int) -> BasicResult {
    return provider.rx.request(.deleteDream(id))
      .asObservable()
      .filterSuccessfulStatusCodes()
      .map { _ in nil }
      .catchError { [unowned self] in self.catchMongliError($0) }
  }

  func readMonthlyDreams(_ month: String) -> MonthlyDreamsResult {
    return provider.rx.request(.readMonthlyDreams(month))
      .asObservable()
      .filterSuccessfulStatusCodes()
      .map(MonthlyDreams.self)
      .map { ($0, nil) }
      .catchError { [unowned self] in self.catchMongliError($0).map { (nil, $0) } }
  }

  func readDailyDreams(_ date: String) -> DreamSummaryResult {
    return provider.rx.request(.readDailyDreams(date))
      .asObservable()
      .filterSuccessfulStatusCodes()
      .map(DreamSummaryJSON.self)
      .map { json -> ([DreamSummary]?, LocalizedString?) in
        guard let dreams = json["dreams"] else { return (nil, .unknownErrorMsg) }
        return (dreams, nil)
      }
      .catchError { [unowned self] in self.catchMongliError($0).map { (nil, $0) } }
  }

  func deleteDailyDreams(_ date: String) -> BasicResult {
    return provider.rx.request(.deleteDailyDreams(date))
      .asObservable()
      .filterSuccessfulStatusCodes()
      .map { _ in nil }
      .catchError { [unowned self] in self.catchMongliError($0) }
  }

  func searchDream(_ query: DreamQuery) -> DreamSummaryResult {
    return provider.rx.request(.searchDream(query))
      .asObservable()
      .filterSuccessfulStatusCodes()
      .map(DreamSummaryJSON.self)
      .map { json -> ([DreamSummary]?, LocalizedString?) in
        guard let dreams = json["dreams"] else { return (nil, .unknownErrorMsg) }
        return (dreams, nil)
      }
      .catchError { [unowned self] in self.catchMongliError($0).map { (nil, $0) } }
  }
}
