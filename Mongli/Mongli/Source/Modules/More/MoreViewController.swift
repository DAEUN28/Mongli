//
//  MoreViewController.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/20.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import ReactorKit
import RxSwift
import RxCocoa

class MoreViewController: BaseViewController, View {
  typealias Reactor = MoreViewReactor

  var reactor: Reactor?

  init(_ reactor: Reactor) {
    self.reactor = reactor
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func bind(reactor: Reactor) {

  }
}
