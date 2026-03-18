import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    let user: User

    var body: some View {
        List {
            // User Info Section
            Section {
                HStack(spacing: BlitSpacing.medium) {
                    AvatarView(
                        name: user.name,
                        avatarURL: user.avatarURL,
                        size: 64
                    )

                    VStack(alignment: .leading, spacing: BlitSpacing.xxsmall) {
                        Text(user.name)
                            .font(BlitFont.headline)
                            .foregroundStyle(Color.blitDark)

                        Text(user.email)
                            .font(BlitFont.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, BlitSpacing.small)
            }

            // App Info Section
            Section {
                HStack {
                    Text("Version")
                        .foregroundStyle(Color.blitDark)
                    Spacer()
                    Text(appVersion)
                        .foregroundStyle(.secondary)
                }
            }

            // Sign Out Section
            Section {
                Button(role: .destructive) {
                    Task {
                        await appState.signOut()
                        dismiss()
                    }
                } label: {
                    HStack {
                        Spacer()
                        Text("Sign Out")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    dismiss()
                }
                .foregroundStyle(Color.blitDark)
            }
        }
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}
