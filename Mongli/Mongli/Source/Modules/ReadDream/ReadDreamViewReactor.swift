//
//  ReadDreamViewReactor.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/20.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

import ReactorKit
import RxCocoa
import RxSwift

final class ReadDreamViewReactor: Reactor {
  var initialState: String = ""

  typealias Action = NoAction

  typealias State = String

  private let service: DreamService
  private let id: Int

  init(_ service: DreamService, id: Int) {
    self.service = service
    self.id = id
  }
}
