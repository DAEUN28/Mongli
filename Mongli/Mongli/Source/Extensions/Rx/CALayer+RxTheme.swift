//
//  CALayer+RxTheme.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/24.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

import RxCocoa
import RxTheme
import RxSwift

extension ThemeProxy where Base == CALayer {
  var backgroundGradient: Observable<CAGradientLayer?> {
    get { return .empty() }
    set {
      let disposable = newValue
        .takeUntil(base.rx.deallocating)
        .observeOn(MainScheduler.instance)
        .bind(to: base.rx.backgroundGradient)
      hold(disposable, for: "backgroundGradient")
    }
  }
}

extension Reactive where Base == CALayer {
  var backgroundGradient: Binder<CAGradientLayer?> {
    return Binder(self.base) { view, attr in
      guard let attr = attr else { return }
      attr.frame = view.bounds
      if let sublayer = view.sublayers?[0] {
        return view.replaceSublayer(sublayer, with: attr)
      }
      return view.insertSublayer(attr, at: 0)
    }
  }
}
