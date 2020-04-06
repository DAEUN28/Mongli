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

  var headerTitleColor: Observable<UIColor?> {
    get { return .empty() }
    set {
      let disposable = newValue
        .takeUntil(base.rx.deallocating)
        .observeOn(MainScheduler.instance)
        .bind(to: base.rx.headerTitleColor)
      hold(disposable, for: "headerTitleColor")
    }
  }

  var weekdayTextColor: Observable<UIColor?> {
    get { return .empty() }
    set {
      let disposable = newValue
        .takeUntil(base.rx.deallocating)
        .observeOn(MainScheduler.instance)
        .bind(to: base.rx.weekdayTextColor)
      hold(disposable, for: "weekdayTextColor")
    }
  }

  var titleDefaultColor: Observable<UIColor?> {
    get { return .empty() }
    set {
      let disposable = newValue
        .takeUntil(base.rx.deallocating)
        .observeOn(MainScheduler.instance)
        .bind(to: base.rx.titleDefaultColor)
      hold(disposable, for: "titleDefaultColor")
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

  var headerTitleColor: Binder<UIColor?> {
    return Binder(self.base) { view, attr in
      view.headerTitleColor = attr
    }
  }

  var weekdayTextColor: Binder<UIColor?> {
     return Binder(self.base) { view, attr in
       view.weekdayTextColor = attr
     }
   }

  var titleDefaultColor: Binder<UIColor?> {
    return Binder(self.base) { view, attr in
      view.titleDefaultColor = attr
    }
  }
}
