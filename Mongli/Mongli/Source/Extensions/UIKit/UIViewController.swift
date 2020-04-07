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
    case cancelWrite
  }

  func showToast(_ message: LocalizedString) {
    let toast = ToastView(message)
    self.view.addSubview(toast)
  }

  func presentAlert(_ type: AlertType,
                    title: LocalizedString? = nil,
                    message: LocalizedString? = nil,
                    handler: ((UIAlertAction) -> Void)? = nil) {

    let alert = UIAlertController(title: title?.localized,
                                  message: message?.localized,
                                  preferredStyle: .alert)

    switch type {
    case .delete(let dream):
      alert.title = title?.localizedDate(dateFormatter.date(from: dream)) ?? "" + LocalizedString.delete.localized
      alert.message = LocalizedString.deleteDreamDesc.localized
      let delete = UIAlertAction(title: LocalizedString.delete.localized, style: .destructive, handler: handler)
      let cancel = UIAlertAction(title: LocalizedString.cancel.localized, style: .cancel, handler: nil)
      alert.addAction(delete)
      alert.addAction(cancel)

    case .cancelWrite:
      alert.title = ""
      alert.message = LocalizedString.cancelDreamDesc.localized
      let continueAction = UIAlertAction(title: LocalizedString.delete.localized, style: .cancel, handler: nil)
      let cancel = UIAlertAction(title: LocalizedString.cancel.localized, style: .destructive, handler: handler)
      alert.addAction(continueAction)
      alert.addAction(cancel)

    default:
      break
    }

    self.present(alert, animated: true)
  }

  func presentDatepickerActionSheet(_ handler: @escaping (Date) -> Void) {
    let datePicker = UIDatePicker()
    datePicker.locale = Locale.current
    datePicker.datePickerMode = .date

    let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    let select = UIAlertAction(title: LocalizedString.select.localized,
                               style: .default) { _ in handler(datePicker.date) }
    let cancel = UIAlertAction(title: LocalizedString.cancel.localized, style: .cancel)
    actionSheet.view.addSubview(datePicker)
    actionSheet.addAction(select)
    actionSheet.addAction(cancel)

    actionSheet.view.snp.makeConstraints {
      $0.height.equalTo(300)
    }
    datePicker.snp.makeConstraints {
      $0.height.equalTo(200)
      $0.leading.equalToSuperview()
      $0.trailing.equalToSuperview()
    }

    self.present(actionSheet, animated: true)
  }
}
