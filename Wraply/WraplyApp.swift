//
//  WraplyApp.swift
//  Wraply
//
//  Created by Michael Fluharty on 4/7/26.
//

import SwiftUI
import SwiftData

@main
struct WraplyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Bookmark.self)
    }
}
