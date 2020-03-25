//
//  MongliStep.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/19.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

import RxFlow

enum MongliStep: Step {
  // Global
  case toast(LocalizedString)
  case unauthorized
  case dismiss
  case categoryInfoIsRequired
  case popoverDatePickerIsRequired
  case popoverDatePickerIsComplete(Date)

  // SignIn
  case signInIsRequired
  case userIsSignedIn

  // Home
  case homeIsRequired

  // Search
  case searchIsRequired
  case filterIsRequired(SearchQuery?)
  case filterIsComplete(SearchQuery)

  // More
  case moreIsRequired
  case contactIsRequired
  case openSourceLisenceIsRequired

  // CreateDream
  case createDreamIsRequired
  case createDreamIsComplete

  // ReadDream
  case readDreamIsRequired(Int)
  case deleteDreamIsComplete

  // UpdateDream
  case updateDreamIsRequired
  case updateDreamIsComplete
}
