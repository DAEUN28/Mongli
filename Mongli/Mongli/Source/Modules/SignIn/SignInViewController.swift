//
//  SignInViewController.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/15.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import ReactorKit
import RxSwift
import RxCocoa

class SignInViewController: BaseViewController, View {
  typealias Reactor = SignInViewReactor

  var reactor: Reactor?
  var disposeBag = DisposeBag()

  init(_ reactor: Reactor) {
    self.reactor = reactor
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func bind(reactor: Reactor) {

  }
}
