//
//  BaseViewController.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/19.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation
import UIKit

class BaseViewController: UIViewController {
  lazy private var className: String = {
    return type(of: self).description().components(separatedBy: ".").last ?? ""
  }()

  deinit {
    log.info("DEINIT: \(self.className)")
  }
}
