//
//  FeedbackView.swift
//  Wraply
//
//  Created by Michael Fluharty on 4/7/26.
//

import SwiftUI
#if canImport(MessageUI)
import MessageUI
#endif

struct FeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var feedbackType = "Bug Report"
    @State private var feedbackText = ""
    @State private var showMailCompose = false
    @State private var showMailUnavailable = false

    let feedbackTypes = ["Bug Report", "Feature Request"]
    let feedbackEmail = "michael.fluharty@mac.com"

    var body: some View {
        NavigationStack {
            Form {
                Picker("Type", selection: $feedbackType) {
                    ForEach(feedbackTypes, id: \.self) { type in
                        Text(type)
                    }
                }
                .pickerStyle(.segmented)
                .font(.system(size: 18))

                Section("Your Feedback") {
                    TextEditor(text: $feedbackText)
                        .frame(minHeight: 150)
                        .font(.system(size: 18))
                }

                Button("Send") {
                    #if canImport(MessageUI)
                    if MFMailComposeViewController.canSendMail() {
                        showMailCompose = true
                    } else {
                        showMailUnavailable = true
                    }
                    #else
                    let subject = "Wraply \(feedbackType) — v\(appVersion)"
                    let body = feedbackText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    if let url = URL(string: "mailto:\(feedbackEmail)?subject=\(subject)&body=\(body)") {
                        #if os(macOS)
                        NSWorkspace.shared.open(url)
                        #endif
                    }
                    #endif
                }
                .font(.system(size: 18))
                .disabled(feedbackText.isEmpty)
            }
            .navigationTitle("Send Feedback")
            #if os(iOS)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .font(.system(size: 18))
                }
            }
            .sheet(isPresented: $showMailCompose) {
                MailComposeView(
                    recipient: feedbackEmail,
                    subject: "Wraply \(feedbackType) — v\(appVersion)",
                    body: feedbackText + "\n\n" + deviceInfo
                )
            }
            #endif
            .alert("Mail Not Available", isPresented: $showMailUnavailable) {
                Button("OK") {}
            } message: {
                Text("Email \(feedbackEmail) directly.")
            }
        }
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
        return "\(version) (\(build))"
    }

    #if os(iOS)
    private var deviceInfo: String {
        let device = UIDevice.current
        var systemInfo = utsname()
        uname(&systemInfo)
        let model = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingCString: $0) ?? "Unknown"
            }
        }
        let storage = (try? URL(fileURLWithPath: NSHomeDirectory())
            .resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
            .volumeAvailableCapacityForImportantUsage)
            .map { ByteCountFormatter.string(fromByteCount: $0, countStyle: .file) } ?? "Unknown"

        return """
        --- Device Info ---
        App: Wraply v\(appVersion)
        Device: \(model)
        System: \(device.systemName) \(device.systemVersion)
        Storage Available: \(storage)
        Locale: \(Locale.current.identifier)
        """
    }
    #endif
}

#if canImport(MessageUI)
struct MailComposeView: UIViewControllerRepresentable {
    let recipient: String
    let subject: String
    let body: String
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setToRecipients([recipient])
        vc.setSubject(subject)
        vc.setMessageBody(body, isHTML: false)
        vc.mailComposeDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(dismiss: dismiss) }

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let dismiss: DismissAction
        init(dismiss: DismissAction) { self.dismiss = dismiss }
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            dismiss()
        }
    }
}
#endif
