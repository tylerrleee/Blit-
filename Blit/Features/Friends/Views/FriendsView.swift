import SwiftUI

struct FriendsView: View {
    var body: some View {
        ZStack {
            Color.blitBackground
                .ignoresSafeArea()

            VStack(spacing: BlitSpacing.medium) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.blitDark.opacity(0.3))

                Text("No friends yet")
                    .font(BlitFont.title)
                    .foregroundStyle(Color.blitDark)

                Text("Invite friends to split bills")
                    .font(BlitFont.callout)
                    .foregroundStyle(Color.blitDark.opacity(0.6))
            }
        }
        .navigationTitle("Friends")
    }
}
