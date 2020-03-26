//
//  RxFlow.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/20.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

import RxFlow

extension OneStepper {
  convenience init(_ step: MongliStep) {
    self.init(withSingleStep: step)
  }
}