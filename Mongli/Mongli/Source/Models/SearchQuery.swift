//
//  SearchQuery.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/22.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

struct SearchQuery: Codable {
  let page: Int
  let criteria: Int
  let alignment: Int
  let category: Int?
  let period: String?
  let keyword: String?
}
