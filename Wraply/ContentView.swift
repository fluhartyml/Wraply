//
//  ContentView.swift
//  Wraply
//
//  Created by Michael Fluharty on 4/7/26.
//

import SwiftUI
import SwiftData
import WebKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var urlString: String = "https://fluharty.me/projects/swift-bible.html"
    @State private var webView = WKWebView()
    @State private var showShareSheet = false
    @State private var showBookmarks = false
    @State private var showAbout = false
    @State private var showBookmarkSaved = false

    var body: some View {
        TabView {
            Tab("Browser", systemImage: "globe") {
                browserView
            }
            Tab("Under the Hood", systemImage: "wrench.and.screwdriver") {
                UnderTheHoodView()
            }
        }
        .font(.system(size: 18))
    }

    private var browserView: some View {
        VStack(spacing: 0) {
            // URL Bar
            HStack {
                TextField("Enter URL", text: $urlString)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
                    .onSubmit {
                        loadURL()
                    }
                    .font(.system(size: 18))

                Button("Go") {
                    loadURL()
                }
                .font(.system(size: 18))
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)
            .padding(.top, 8)

            // Toolbar
            HStack {
                Button(action: { webView.goBack() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20))
                }

                Button(action: { webView.goForward() }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 20))
                }

                Button(action: { webView.reload() }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 20))
                }

                Button(action: { showShareSheet = true }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 20))
                }

                Button(action: { saveBookmark() }) {
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 20))
                }

                Button(action: { showBookmarks = true }) {
                    Image(systemName: "book")
                        .font(.system(size: 20))
                }

                Spacer()

                Button(action: { showAbout = true }) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 20))
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)

            Divider()

            // Web View
            WebViewRepresentable(webView: webView)
        }
        .onAppear {
            loadURL()
        }
        .overlay(alignment: .top) {
            if showBookmarkSaved {
                Text("Bookmark Saved")
                    .font(.system(size: 16, weight: .medium))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 8)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            let shareURL = webView.url ?? URL(string: urlString)!
            ActivityView(activityItems: [shareURL])
        }
        .sheet(isPresented: $showBookmarks) {
            BookmarksView { urlString in
                self.urlString = urlString
                loadURL()
            }
        }
        .sheet(isPresented: $showAbout) {
            AboutView()
        }
    }

    private func loadURL() {
        var address = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        if !address.hasPrefix("http://") && !address.hasPrefix("https://") {
            address = "https://" + address
        }
        if let url = URL(string: address) {
            webView.load(URLRequest(url: url))
        }
    }

    private func saveBookmark() {
        let title = webView.title ?? urlString
        let url = webView.url?.absoluteString ?? urlString
        let bookmark = Bookmark(title: title, urlString: url)
        modelContext.insert(bookmark)
        withAnimation {
            showBookmarkSaved = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showBookmarkSaved = false
            }
        }
    }
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
