//
//  Spinner+Rx.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/26.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import RxCocoa
import RxSwift

extension Reactive where Base: Spinner {
  var isAnimating: Binder<Bool> {
    return Binder(self.base) { view, active in
      if active {
        view.indicator.startAnimating()
        view.isHidden = false
      } else {
        view.indicator.stopAnimating()
        view.isHidden = true
      }
    }
  }
}
