//
//  UIViewController.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/23.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

extension UIViewController {
  func showToast(_ message: LocalizedString) {
    let toast = ToastView(message)
    self.view.addSubview(toast)
  }
}
