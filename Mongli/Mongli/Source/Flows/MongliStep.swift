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
  case toast(_ message: LocalizedString)
  case unauthorized
  case dismiss
  case categoryInfoIsRequired
  case popoverDatePickerIsRequired
  case popoverDatePickerIsComplete(_ date: Date)

  // SignIn
  case signInIsRequired
  case userIsSignedIn

  // Home
  case homeIsRequired
  case dreamIsPicked(_ id: Int)

  // Search
  case searchIsRequired
  case filterIsRequired(_ existingFilter: DreamQuery?)
  case filterIsComplete(_ filter: DreamQuery)

  // More
  case moreIsRequired
  case contactIsRequired
  case openSourceLisenceIsRequired

  // CreateDream
  case createDreamIsRequired
  case createDreamIsComplete

  // ReadDream
  case readDreamIsRequired(_ id: Int)
  case deleteDreamIsComplete

  // UpdateDream
  case updateDreamIsRequired
  case updateDreamIsComplete
}
