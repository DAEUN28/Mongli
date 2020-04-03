//
//  UILabel+RxTheme.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/04/02.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import RxCocoa
import RxTheme
import RxSwift

extension ThemeProxy where Base: UILabel {
  var textAttributes: Observable<NSMutableAttributedString?> {
    get { return .empty() }
    set {
      let disposable = newValue
        .takeUntil(base.rx.deallocating)
        .observeOn(MainScheduler.instance)
        .bind(to: base.rx.textAttributes)
      hold(disposable, for: "textAttributes")
    }
  }
}

extension Reactive where Base: UILabel {
  var textAttributes: Binder<NSMutableAttributedString?> {
    return Binder(self.base) { view, attr in
      view.attributedText = attr
    }
  }
}
