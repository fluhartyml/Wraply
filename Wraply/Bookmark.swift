//
//  Bookmark.swift
//  Wraply
//
//  Created by Michael Fluharty on 4/7/26.
//

import SwiftData
import Foundation

@Model
class Bookmark {
    var title: String
    var urlString: String
    var dateAdded: Date

    init(title: String, urlString: String, dateAdded: Date = .now) {
        self.title = title
        self.urlString = urlString
        self.dateAdded = dateAdded
    }
}
