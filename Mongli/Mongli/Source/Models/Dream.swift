//
//  Dream.swift
//  Mongli
//
//  Created by DaEun Kim on 2020/03/17.
//  Copyright © 2020 DaEun Kim. All rights reserved.
//

import Foundation

struct Dream: Codable, Equatable {
  var id: Int?
  var date: String
  var category: Int
  var title: String
  var content: String

  init(id: Int? = nil,
       date: String = "",
       category: Int = 0,
       title: String = "",
       content: String = "") {
    self.id = id
    self.date = date
    self.category = category
    self.title = title
    self.content = content
  }

  func newDream(id: Int? = nil,
                date: String? = nil,
                category: Int? = nil,
                title: String? = nil,
                content: String? = nil) -> Dream {
    var newDream = self
    if let id = id { newDream.id = id }
    if let date = date { newDream.date = date }
    if let category = category { newDream.category = category }
    if let title = title { newDream.title = title }
    if let content = content { newDream.content = content }
    return newDream
  }

  func isEmpty() -> Bool {
    return self.date.isEmpty || self.title.isEmpty || self.content.isEmpty
  }
}

struct SummaryDream: Codable, Equatable {
  let id: Int
  let date: String?
  let category: Int
  let title: String
  let summary: String
}

struct SummaryDreams: Codable {
  let total: Int?
  let dreams: [SummaryDream]
}
