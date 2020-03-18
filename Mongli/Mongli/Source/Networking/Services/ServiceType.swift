//
//  ServiceType.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/18.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

import RxSwift

typealias StringJSON = [String: String]
typealias DreamSummaryJSON = [String: [DreamSummary]]
typealias MonthlyDreams = [String: [Int]]

protocol ServiceType {
  typealias BasicResult = Observable<LocalizedString?>
  typealias AnalysisResult = Observable<(UserAnalysis?, LocalizedString?)>
  typealias DreamResult = Observable<(Dream?, LocalizedString?)>
  typealias MonthlyDreamsResult = Observable<(MonthlyDreams?, LocalizedString?)>
  typealias DreamSummaryResult = Observable<([DreamSummary]?, LocalizedString?)>

  var currentUserInfo: UserInfo? { get }
}

protocol AuthServiceType: ServiceType {
  var currentUserAnalysis: UserAnalysis? { get }

  func logout() -> BasicResult
  func deleteUser() -> BasicResult
  func rename(_ name: String) -> BasicResult
  func readAnalysis() -> AnalysisResult
}

protocol DreamServiceType: ServiceType {
  func createDream(_ dream: Dream) -> BasicResult
  func readDream(_ id: Int) -> DreamResult
  func updateDream(_ dream: Dream) -> BasicResult
  func deleteDream(_ id: Int) -> BasicResult
  func readMonthlyDreams(_ month: String) -> MonthlyDreamsResult
  func readDailyDreams(_ date: String) -> DreamSummaryResult
  func deleteDailyDreams(_ date: String) -> BasicResult
  func searchDream(_ query: DreamQuery) -> DreamSummaryResult
}