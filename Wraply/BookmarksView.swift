//
//  BookmarksView.swift
//  Wraply
//
//  Created by Michael Fluharty on 4/7/26.
//

import SwiftUI
import SwiftData

struct BookmarksView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Bookmark.dateAdded, order: .reverse) private var bookmarks: [Bookmark]

    var onSelect: (String) -> Void

    var body: some View {
        NavigationStack {
            List {
                if bookmarks.isEmpty {
                    Text("No bookmarks yet.")
                        .foregroundStyle(.secondary)
                        .font(.system(size: 18))
                } else {
                    ForEach(bookmarks) { bookmark in
                        Button {
                            onSelect(bookmark.urlString)
                            dismiss()
                        } label: {
                            VStack(alignment: .leading) {
                                Text(bookmark.title)
                                    .font(.system(size: 18))
                                Text(bookmark.urlString)
                                    .font(.system(size: 14))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete(perform: deleteBookmarks)
                }
            }
            .navigationTitle("Bookmarks")
            #if os(iOS)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 18))
                }
            }
            #endif
        }
    }

    private func deleteBookmarks(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(bookmarks[index])
        }
    }
}
