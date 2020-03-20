//
//  MoreViewReactor.swift
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

final class MoreViewReactor: Reactor, Stepper {
  var initialState: String = ""

  typealias Action = NoAction

  typealias State = String

  var steps = PublishRelay<Step>()

  let service: AuthService

  init(_ service: AuthService) {
    self.service = service
  }
}
