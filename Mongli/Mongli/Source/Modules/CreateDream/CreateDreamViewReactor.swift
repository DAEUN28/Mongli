//
//  CreateDreamViewReactor.swift
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

final class CreateDreamViewReactor: Reactor {
  var initialState: String = ""

  typealias Action = NoAction

  typealias State = String

  let service: DreamService

  init(_ service: DreamService) {
    self.service = service
  }
}
