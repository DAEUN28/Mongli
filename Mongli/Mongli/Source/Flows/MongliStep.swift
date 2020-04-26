//
//  MongliStep.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/19.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import RxFlow

enum MongliStep: Step {
  // Global
  case toast(LocalizedString)
  case alert(_ type: UIViewController.AlertType, handler: ((UIAlertAction) -> Void)? = nil)
  case datePickerActionSheet((Date) -> Void)
  case unauthorized
  case popVC
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
  case filterIsRequired(SearchQuery)
  case filterIsComplete(SearchQuery)

  // More
  case moreIsRequired
  case accountManagementIsRequired(logoutHandler: ((UIAlertAction) -> Void),
    deleteUserHandler: ((UIAlertAction) -> Void),
    renameHandler: ((String?) -> Void))
  case opensourceLisenceIsRequired
  case contactIsRequired

  // CreateDream
  case createDreamIsRequired

  // ReadDream
  case readDreamIsRequired(Int)
  case deleteDreamIsComplete

  // UpdateDream
  case updateDreamIsRequired(Dream)
  case updateDreamIsComplete(Dream)
}
