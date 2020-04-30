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
    case deleteDream(String)
    case deleteDreams(Date)
    case deleteUser
    case rename((String?) -> Void)
    case cancelWrite
  }

  func showToast(_ message: LocalizedString) {
    let toast = ToastView(message)
    self.view.addSubview(toast)
  }

  func presentAlert(_ type: AlertType,
                    handler: ((UIAlertAction) -> Void)? = nil) {

    let alert = UIAlertController(title: nil, message: nil, style: .alert)

    switch type {
    case .deleteDream(let dream):
      alert.title = dream + LocalizedString.delete.localized
      alert.setMessage(message: .deleteDreamDesc)
      let delete = UIAlertAction(title: .delete, style: .destructive, handler: handler)
      let cancel = UIAlertAction(title: .cancel, style: .cancel, handler: nil)
      alert.addAction(delete)
      alert.addAction(cancel)

    case .deleteDreams(let date):
      alert.title = LocalizedString.dateFormat.localizedDate(date, .allTheDreamsAdverb)
      alert.setMessage(message: .deleteDreamDesc)
      let delete = UIAlertAction(title: .delete, style: .destructive, handler: handler)
      let cancel = UIAlertAction(title: .cancel, style: .cancel, handler: nil)
      alert.addAction(delete)
      alert.addAction(cancel)

    case .deleteUser:
      alert.setTitle(title: .deleteUser)
      alert.setMessage(message: .deleteUserDesc)
      let delete = UIAlertAction(title: .secession, style: .destructive, handler: handler)
      let cancel = UIAlertAction(title: .cancel, style: .cancel, handler: nil)
      alert.addAction(delete)
      alert.addAction(cancel)

    case .rename(let handler):
      alert.setTitle(title: .rename)
      alert.setMessage(message: .renameDesc)
      alert.addTextField { $0.placeholder = LocalizedString.renamePlaceholder.localized }
      let change = UIAlertAction(title: .change, style: .destructive) { _ in
        handler(alert.textFields?[0].text)
      }
      let cancel = UIAlertAction(title: .cancel, style: .cancel, handler: nil)
      alert.addAction(change)
      alert.addAction(cancel)

    case .cancelWrite:
      alert.title = ""
      alert.setMessage(message: .cancelDreamDesc)
      let continueAction = UIAlertAction(title: .continue, style: .cancel, handler: nil)
      let cancel = UIAlertAction(title: .cancel, style: .destructive, handler: { [weak self] _ in
        self?.navigationController?.popViewController(animated: true)
      })
      alert.addAction(continueAction)
      alert.addAction(cancel)
    }

    self.present(alert, animated: true)
  }

  func presentDatepickerActionSheet(_ handler: @escaping (Date) -> Void) {
    let datePicker = UIDatePicker()
    datePicker.locale = Locale.current
    datePicker.datePickerMode = .date

    let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    let select = UIAlertAction(title: .select, style: .default) { _ in handler(datePicker.date) }
    let cancel = UIAlertAction(title: .cancel, style: .cancel)
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
