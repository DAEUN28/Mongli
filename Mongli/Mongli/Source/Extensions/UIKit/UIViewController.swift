//
//  UIViewController.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/23.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import UIKit

extension UIViewController {

  enum AlertType {
    case delete(String)
    case deleteAccount
    case update
  }

  func showToast(_ message: LocalizedString) {
    let toast = ToastView(message)
    self.view.addSubview(toast)
  }

  func presentAlert(_ type: AlertType,
                    title: LocalizedString?,
                    message: LocalizedString?,
                    handler: ((UIAlertAction) -> Void)?) {

    let alert = UIAlertController(title: title?.localized,
                                  message: message?.localized,
                                  preferredStyle: .alert)
    let cancel = UIAlertAction(title: LocalizedString.cancel.localized, style: .cancel, handler: nil)
    alert.addAction(cancel)

    switch type {
    case .delete(let dream):
      alert.title = title?.localizedDateString(dream) ?? "" + LocalizedString.delete.localized
      let delete = UIAlertAction(title: LocalizedString.delete.localized, style: .destructive, handler: handler)
      alert.addAction(delete)

    default:
      break
    }

    self.present(alert, animated: true)
  }
}
