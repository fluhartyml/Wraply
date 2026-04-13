//
//  AboutView.swift
//  Wraply
//
//  Created by Michael Fluharty on 4/7/26.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showFeedback = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 8) {
                        Image(systemName: "globe")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundStyle(.tint)
                        Text("Wraply")
                            .font(.system(size: 24, weight: .bold))
                        Text("v\(appVersion)")
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                }

                Section {
                    Text("Michael Lee Fluharty")
                        .font(.system(size: 18))
                    Text("Engineered with Claude by Anthropic")
                        .font(.system(size: 18))
                        .foregroundStyle(.secondary)
                }

                Section {
                    Button {
                        showFeedback = true
                    } label: {
                        Label("Send Feedback", systemImage: "envelope")
                            .font(.system(size: 18))
                    }
                }
            }
            .navigationTitle("About")
            #if os(iOS)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 18))
                }
            }
            #endif
            .sheet(isPresented: $showFeedback) {
                FeedbackView()
            }
        }
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
        return "\(version) (\(build))"
    }
}
