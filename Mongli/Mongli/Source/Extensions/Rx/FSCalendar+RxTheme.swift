//
//  FSCalendar+RxTheme.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/25.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

import FSCalendar
import RxCocoa
import RxTheme
import RxSwift

extension ThemeProxy where Base == FSCalendarAppearance {
  var titleSelectionColor: Observable<UIColor?> {
    get { return .empty() }
    set {
      let disposable = newValue
        .takeUntil(base.rx.deallocating)
        .observeOn(MainScheduler.instance)
        .bind(to: base.rx.titleSelectionColor)
      hold(disposable, for: "titleSelectionColor")
    }
  }

  var titleTodayColor: Observable<UIColor?> {
    get { return .empty() }
    set {
      let disposable = newValue
        .takeUntil(base.rx.deallocating)
        .observeOn(MainScheduler.instance)
        .bind(to: base.rx.titleTodayColor)
      hold(disposable, for: "titleTodayColor")
    }
  }
}

extension Reactive where Base == FSCalendarAppearance {
  var titleSelectionColor: Binder<UIColor?> {
    return Binder(self.base) { view, attr in
      view.titleSelectionColor = attr
    }
  }

  var titleTodayColor: Binder<UIColor?> {
    return Binder(self.base) { view, attr in
      view.titleTodayColor = attr
    }
  }
}
