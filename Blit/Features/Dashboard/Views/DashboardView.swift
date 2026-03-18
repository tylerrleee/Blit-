import SwiftUI

struct DashboardView: View {
    @Bindable var viewModel: DashboardViewModel
    var onScanReceipt: () -> Void = {}
    var onPhotoLibrary: () -> Void = {}
    var onSeeAllHistory: () -> Void = {}
    var onSelectReceipt: (Receipt) -> Void = { _ in }
    var onAvatarTap: () -> Void = {}

    @State private var participantCounts: [UUID: Int] = [:]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BlitSpacing.large) {
                headerSection
                scanCard
                recentSplitsSection
            }
            .padding(.horizontal, BlitSpacing.medium)
            .padding(.top, BlitSpacing.medium)
        }
        .background(Color.blitBackground)
        .task {
            await viewModel.loadReceipts()
            await loadParticipantCounts()
        }
        .refreshable {
            await viewModel.loadReceipts()
            await loadParticipantCounts()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: BlitSpacing.xxsmall) {
                let parts = viewModel.greeting.components(separatedBy: "\n")
                if parts.count == 2 {
                    Text(parts[0])
                        .font(BlitFont.subheadline)
                        .foregroundStyle(Color.blitDark.opacity(0.7))
                    Text(parts[1])
                        .font(BlitFont.largeTitle)
                        .foregroundStyle(Color.blitDark)
                } else {
                    Text(viewModel.greeting)
                        .font(BlitFont.largeTitle)
                        .foregroundStyle(Color.blitDark)
                }
            }

            Spacer()

            Button(action: onAvatarTap) {
                AvatarView(
                    name: viewModel.currentUser.name,
                    avatarURL: viewModel.currentUser.avatarURL,
                    size: 48
                )
            }
        }
        .padding(.top, BlitSpacing.small)
    }

    // MARK: - Scan Card

    private var scanCard: some View {
        VStack(spacing: BlitSpacing.medium) {
            Text("Ready to split a bill?")
                .font(BlitFont.title)
                .foregroundStyle(Color.blitDark)
                .frame(maxWidth: .infinity, alignment: .leading)

            BrandButton("Scan Receipt", icon: "camera.fill", style: .primary) {
                onScanReceipt()
            }

            BrandButton("Photo Library", icon: "photo", style: .secondary) {
                onPhotoLibrary()
            }
        }
        .padding(BlitSpacing.large)
        .background(Color.white, in: RoundedRectangle(cornerRadius: BlitCornerRadius.large))
    }

    // MARK: - Recent Splits

    private var recentSplitsSection: some View {
        VStack(alignment: .leading, spacing: BlitSpacing.medium) {
            HStack {
                Text("RECENT SPLITS")
                    .font(BlitFont.sectionHeader)
                    .foregroundStyle(Color.blitDark)

                Spacer()

                Button("See all") {
                    onSeeAllHistory()
                }
                .font(BlitFont.footnote)
                .foregroundStyle(Color.blitOrange)
            }

            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .padding(.vertical, BlitSpacing.xlarge)
            } else if viewModel.recentReceipts.isEmpty {
                emptyState
            } else {
                LazyVStack(spacing: BlitSpacing.small) {
                    ForEach(viewModel.recentReceipts) { receipt in
                        Button {
                            onSelectReceipt(receipt)
                        } label: {
                            RecentSplitCard(
                                receipt: receipt,
                                participantCount: participantCounts[receipt.id] ?? 0
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: BlitSpacing.small) {
            Image(systemName: "receipt")
                .font(.system(size: 36))
                .foregroundStyle(Color.blitDark.opacity(0.3))
            Text("No recent splits")
                .font(BlitFont.callout)
                .foregroundStyle(Color.blitDark.opacity(0.5))
            Text("Scan a receipt to get started!")
                .font(BlitFont.footnote)
                .foregroundStyle(Color.blitDark.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, BlitSpacing.xlarge)
    }

    private func loadParticipantCounts() async {
        let receipts = viewModel.recentReceipts
        await withTaskGroup(of: (UUID, Int).self) { group in
            for receipt in receipts {
                group.addTask {
                    let count = await viewModel.participantCount(for: receipt.id)
                    return (receipt.id, count)
                }
            }
            for await (id, count) in group {
                participantCounts[id] = count
            }
        }
    }
}
