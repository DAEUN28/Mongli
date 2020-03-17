//
//  Dream.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/17.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

struct Dream: Codable {
  let id: Int?
  let date: String
  let category: Int
  let title: String
  let content: String
}

struct DreamSummary: Codable {
  let id: Int
  let date: String?
  let category: Int
  let title: String
  let summary: String
}

struct DreamQuery: Codable {
  let page: Int
  let criteria: Int
  let alignment: Int
  let category: Int?
  let period: String?
  let keyword: String?
}
