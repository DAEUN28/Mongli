//
//  UIGestureRecognizer+Rx.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/04/02.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

extension Reactive where Base: UIGestureRecognizer {
  var touchesMoved: Observable<Void> {
    let selector = #selector(Base.touchesMoved(_:with:))
    return self.methodInvoked(selector)
      .map { _ in () }
  }
}
