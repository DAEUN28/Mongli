//
//  UIViewController+Rx.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/04/26.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift

extension Reactive where Base: UIViewController {
  var viewWillAppear: ControlEvent<Bool> {
    let source = self.methodInvoked(#selector(Base.viewWillAppear)).map { $0.first as? Bool ?? false }
    return ControlEvent(events: source)
  }

  var viewWillDisappear: ControlEvent<Bool> {
    let source = self.methodInvoked(#selector(Base.willMove(toParent:))).map { $0.first as? Bool ?? false }
    return ControlEvent(events: source)
  }
}
