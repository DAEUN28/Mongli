//
//  UISegmentedControl.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/04/05.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

import RxCocoa
import RxTheme
import RxSwift

extension ThemeProxy where Base: UISegmentedControl {
  var selectedSegmentTintColor: Observable<UIColor?> {
    get { return .empty() }
    set {
      let disposable = newValue
        .takeUntil(base.rx.deallocating)
        .observeOn(MainScheduler.instance)
        .bind(to: base.rx.selectedSegmentTintColor)
      hold(disposable, for: "selectedSegmentTintColor")
    }
  }

  var segmentTitleAttribute: Observable<[NSAttributedString.Key: Any]?> {
    get { return .empty() }
    set {
      let disposable = newValue
        .takeUntil(base.rx.deallocating)
        .observeOn(MainScheduler.instance)
        .bind(to: base.rx.segmentTitleAttribute)
      hold(disposable, for: "segmentTitleAttribute")
    }
  }
}

extension Reactive where Base: UISegmentedControl {
  var selectedSegmentTintColor: Binder<UIColor?> {
    return Binder(self.base) { view, attr in
      view.selectedSegmentTintColor = attr
    }
  }

  var segmentTitleAttribute: Binder<[NSAttributedString.Key: Any]?> {
    return Binder(self.base) { view, attr in
      view.setTitleTextAttributes(attr, for: .normal)
    }
  }
}
