import SwiftUI

struct AvatarView: View {
    let name: String
    let avatarURL: String?
    var size: CGFloat = 48
    var borderColor: Color = .blitOrange

    var body: some View {
        Group {
            if let avatarURL, let url = URL(string: avatarURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        initialsView
                    case .empty:
                        ProgressView()
                            .frame(width: size, height: size)
                    @unknown default:
                        initialsView
                    }
                }
            } else {
                initialsView
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay {
            Circle()
                .stroke(borderColor, lineWidth: 2)
        }
    }

    private var initialsView: some View {
        ZStack {
            Color.blitDark
            Text(initials)
                .font(.system(size: size * 0.38, weight: .semibold))
                .foregroundStyle(.white)
        }
    }

    private var initials: String {
        let parts = name.components(separatedBy: " ").filter { !$0.isEmpty }
        let firstInitial = parts.first?.prefix(1) ?? ""
        let lastInitial = parts.count > 1 ? parts.last!.prefix(1) : ""
        return "\(firstInitial)\(lastInitial)".uppercased()
    }
}
