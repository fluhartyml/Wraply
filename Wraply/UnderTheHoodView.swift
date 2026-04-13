//
//  UnderTheHoodView.swift
//  Wraply
//
//  Created by Michael Fluharty on 4/7/26.
//

import SwiftUI

struct UnderTheHoodView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFile: SourceFile?
    @State private var copied = false

    var body: some View {
        NavigationStack {
            List(SourceFile.allFiles) { file in
                Button {
                    selectedFile = file
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(file.name)
                            .font(.system(size: 18, weight: .medium, design: .monospaced))
                        Text(file.description)
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Under the Hood")
            .sheet(item: $selectedFile) { file in
                NavigationStack {
                    ScrollView([.horizontal, .vertical]) {
                        Text(file.source)
                            .font(.system(size: 14, design: .monospaced))
                            .fixedSize(horizontal: true, vertical: false)
                            .padding()
                            .frame(minWidth: 0, alignment: .leading)
                    }
                    .navigationTitle(file.name)
                    #if os(iOS)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Done") { selectedFile = nil }
                                .font(.system(size: 18))
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                UIPasteboard.general.string = file.source
                                copied = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    copied = false
                                }
                            } label: {
                                Label(copied ? "Copied" : "Copy",
                                      systemImage: copied ? "checkmark" : "doc.on.doc")
                                    .font(.system(size: 18))
                            }
                        }
                    }
                    #endif
                }
            }
        }
    }
}

struct SourceFile: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let source: String

    static let allFiles: [SourceFile] = [
        SourceFile(
            name: "WraplyApp.swift",
            description: "App entry point — scene and data container",
            source: """
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
            """
        ),
        SourceFile(
            name: "ContentView.swift",
            description: "Main browser — URL bar, toolbar, web view",
            source: """
            import SwiftUI
            import WebKit

            struct ContentView: View {
                @Environment(\\.modelContext) private var modelContext
                @State private var urlString: String = "https://www.apple.com"
                @State private var webView = WKWebView()
                @State private var showShareSheet = false
                @State private var showBookmarks = false
                @State private var showAbout = false
                @State private var showBookmarkSaved = false

                var body: some View {
                    TabView {
                        Tab("Browser", systemImage: "globe") {
                            // Browser with toolbar, URL bar, web view
                        }
                        Tab("Under the Hood", systemImage: "wrench.and.screwdriver") {
                            UnderTheHoodView()
                        }
                    }
                }

                private func loadURL() { ... }
                private func saveBookmark() { ... }
            }
            """
        ),
        SourceFile(
            name: "WebViewRepresentable.swift",
            description: "UIKit-to-SwiftUI bridge for WKWebView",
            source: """
            import SwiftUI
            import WebKit

            struct WebViewRepresentable: UIViewRepresentable {
                let webView: WKWebView

                func makeUIView(context: Context) -> WKWebView {
                    webView.allowsBackForwardNavigationGestures = true
                    return webView
                }

                func updateUIView(_ uiView: WKWebView, context: Context) {
                    // SwiftUI calls this when state changes.
                    // We handle loading in ContentView, so nothing needed here.
                }
            }
            """
        ),
        SourceFile(
            name: "Bookmark.swift",
            description: "SwiftData model — persistent bookmarks",
            source: """
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
            """
        ),
        SourceFile(
            name: "BookmarksView.swift",
            description: "Bookmark list — tap to navigate, swipe to delete",
            source: """
            import SwiftUI
            import SwiftData

            struct BookmarksView: View {
                @Environment(\\.modelContext) private var modelContext
                @Environment(\\.dismiss) private var dismiss
                @Query(sort: \\Bookmark.dateAdded, order: .reverse)
                private var bookmarks: [Bookmark]

                var onSelect: (String) -> Void

                var body: some View {
                    NavigationStack {
                        List {
                            ForEach(bookmarks) { bookmark in
                                Button { onSelect(bookmark.urlString); dismiss() }
                                // title + URL subtitle
                            }
                            .onDelete(perform: deleteBookmarks)
                        }
                    }
                }
            }
            """
        ),
        SourceFile(
            name: "AboutView.swift",
            description: "App info — icon, version, credits, feedback",
            source: """
            import SwiftUI

            struct AboutView: View {
                @Environment(\\.dismiss) private var dismiss
                @State private var showFeedback = false

                var body: some View {
                    NavigationStack {
                        List {
                            // App icon, name, version
                            // Credits: Michael Lee Fluharty
                            // Engineered with Claude by Anthropic
                            // Send Feedback button
                        }
                    }
                }
            }
            """
        ),
        SourceFile(
            name: "FeedbackView.swift",
            description: "Bug report / feature request email form",
            source: """
            import SwiftUI
            import MessageUI

            struct FeedbackView: View {
                @State private var feedbackType = "Bug Report"
                @State private var feedbackText = ""

                var body: some View {
                    Form {
                        Picker("Type", selection: $feedbackType)
                            .pickerStyle(.segmented)
                        Section("Your Feedback") {
                            TextEditor(text: $feedbackText)
                        }
                        Button("Send") { /* MFMailComposeViewController */ }
                    }
                }
                // Appends device info: model, OS, storage, locale
            }
            """
        ),
    ]
}
