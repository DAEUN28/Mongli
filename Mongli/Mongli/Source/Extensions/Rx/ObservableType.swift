//
//  ObservableType.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/27.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import RxSwift

extension ObservableType {
  func withPrevious() -> Observable<(Element?, Element)> {
    return scan([], accumulator: { Array($0 + [$1]).suffix(2) })
      .map { (arr) -> (previous: Element?, current: Element) in
        (arr.count > 1 ? arr.first : nil, arr.last!)
      }
  }
}
