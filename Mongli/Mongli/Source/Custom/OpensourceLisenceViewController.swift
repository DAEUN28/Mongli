//
//  OpensourceLisenceViewController.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/04/27.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Carte

final class OpensourceLisenceViewController: CarteViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = LocalizedString.opensourceLisence.localized
    self.navigationItem.leftBarButtonItem?.theme.tintColor = themed { $0.primary }
    self.view.theme.backgroundColor = themed { $0.background }
  }
}
