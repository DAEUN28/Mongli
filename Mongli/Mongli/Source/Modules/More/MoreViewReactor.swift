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

  enum Action {
    
  }

  enum Mutation {
    case setError(LocalizedString?)
    case setLoading(Bool)
  }

  struct State {
    var error: LocalizedString?
    var isLoading: Bool = false
  }

  let initialState: State = State()
  private let service: AuthService

  var steps = PublishRelay<Step>()

  init(_ service: AuthService) {
    self.service = service
  }
}
