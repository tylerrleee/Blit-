import SwiftUI

struct LoginView: View {
    @Bindable var viewModel: LoginViewModel

    var body: some View {
        ZStack {
            Color.blitBackground
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Logo
                Image(systemName: "bolt.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.white)
                    .padding(24)
                    .background(Color.blitDark, in: RoundedRectangle(cornerRadius: 16))

                // App name
                Text("Blit")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.blitDark)

                // Tagline
                Text("Lightning fast connections\nfor the modern world.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.blitDark.opacity(0.7))

                Spacer()

                // Continue with Google
                Button {
                    Task { await viewModel.signInWithGoogle() }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "g.circle.fill")
                            .font(.title2)
                        Text("Continue with Google")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(Color.blitDark)
                }
                .disabled(viewModel.isLoading)

                // Sign in with Email — disabled for MVP
                Button {} label: {
                    Text("Sign in with Email")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.gray.opacity(0.3), in: RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(Color.blitDark.opacity(0.5))
                }
                .disabled(true)

                Text("Coming soon")
                    .font(.caption)
                    .foregroundStyle(Color.blitDark.opacity(0.4))

                Spacer()

                // Terms
                VStack(spacing: 4) {
                    Text("By continuing, you agree to our")
                        .font(.caption)
                        .foregroundStyle(Color.blitDark.opacity(0.5))

                    HStack(spacing: 4) {
                        Link("Terms of Service", destination: URL(string: "https://blit.app/terms")!)
                        Text("&")
                        Link("Privacy Policy", destination: URL(string: "https://blit.app/privacy")!)
                    }
                    .font(.caption)
                    .foregroundStyle(Color.blitDark.opacity(0.7))
                }
            }
            .padding(.horizontal, 32)

            // Loading overlay
            if viewModel.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.5)
            }
        }
        .alert("Error", isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.dismissError() } }
        )) {
            Button("OK") { viewModel.dismissError() }
        } message: {
            if let msg = viewModel.errorMessage {
                Text(msg)
            }
        }
    }
}
