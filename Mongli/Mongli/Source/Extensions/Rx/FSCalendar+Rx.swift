//
//  FSCalendar+Rx.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/25.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import FSCalendar
import RxSwift
import RxCocoa

extension Reactive where Base: FSCalendar {
  var delegate: DelegateProxy<FSCalendar, FSCalendarDelegate> {
    return RxFsCalendarDelegate.proxy(for: self.base)
  }

  var calendarCurrentPageDidChange: ControlEvent<Date?> {
    let selector = #selector(FSCalendarDelegate.calendarCurrentPageDidChange(_:))
    let events = delegate.methodInvoked(selector)
      .map { ($0[0] as? FSCalendar)?.currentPage }
    return ControlEvent(events: events)
  }

  var didSelectDate: ControlEvent<Date?> {
    let selector = #selector(FSCalendarDelegate.calendar(_:didSelect:at:))
    let events = delegate.methodInvoked(selector)
      .map { $0[1] as? Date }
    return ControlEvent(events: events)
  }
}

final class RxFsCalendarDelegate: DelegateProxy<FSCalendar, FSCalendarDelegate>,
DelegateProxyType, FSCalendarDelegate {

  static func registerKnownImplementations() {
    self.register { RxFsCalendarDelegate(parentObject: $0, delegateProxy: self) }
  }

  static func currentDelegate(for object: FSCalendar) -> FSCalendarDelegate? {
    return object.delegate
  }

  static func setCurrentDelegate(_ delegate: FSCalendarDelegate?, to object: FSCalendar) {
    object.delegate = delegate
  }
}
