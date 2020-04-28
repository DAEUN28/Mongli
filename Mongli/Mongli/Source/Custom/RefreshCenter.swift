//
//  RefreshCenter.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/04/28.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

import RxCocoa
import RxSwift

final class RefreshCenter {
  static let shared = RefreshCenter()
  private init() {}

  let homeNeedRefresh = BehaviorRelay<Bool>(value: false)
  let moreNeedRefresh = BehaviorRelay<Bool>(value: false)

  func refreshAll() {
    homeNeedRefresh.accept(true)
    moreNeedRefresh.accept(true)
  }
}
