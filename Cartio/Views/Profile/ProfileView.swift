//
//  ProfileView.swift
//  Cartio
//

import SwiftUI
import StoreKit

struct ProfileView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.requestReview) private var requestReview
    @Environment(\.modelContext) private var modelContext
    @ScaledMetric(relativeTo: .title) private var avatarSize: CGFloat = 56
    @State private var viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                CartioMeshBackground()

                ScrollView {
                    VStack(spacing: CartioSpacing.md) {
                        accountSection
                        statsSection
                        menuSection
                        supportSection
                        dangerSection
                    }
                    .padding(.horizontal, CartioSpacing.md)
                    .padding(.vertical, CartioSpacing.sm)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Profile")
                        .font(CartioFonts.headline())
                        .foregroundStyle(CartioColors.textPrimary)
                }
            }
            .task { await viewModel.loadProfile() }
        }
    }

    // MARK: - Account

    private var accountSection: some View {
        HStack(spacing: CartioSpacing.md) {
            Text(viewModel.userInitials)
                .font(CartioFonts.headline())
                .foregroundStyle(.white)
                .frame(width: avatarSize, height: avatarSize)
                .background(CartioGradient.primaryLinear)
                .clipShape(Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: CartioSpacing.xs) {
                Text(viewModel.displayName)
                    .font(CartioFonts.headline())
                    .foregroundStyle(CartioColors.textPrimary)
                Text(viewModel.email)
                    .font(CartioFonts.caption())
                    .foregroundStyle(CartioColors.textSecondary)
            }

            Spacer()

            Text(viewModel.planBadge)
                .font(CartioFonts.caption())
                .padding(.horizontal, CartioSpacing.sm)
                .padding(.vertical, CartioSpacing.xs)
                .background(viewModel.isPremium ? CartioColors.primary.opacity(0.15) : Color.secondary.opacity(0.1))
                .foregroundStyle(viewModel.isPremium ? CartioColors.primary : CartioColors.textSecondary)
                .clipShape(Capsule())
                .accessibilityLabel(viewModel.isPremium ? "Pro plan" : "Free plan")
        }
        .padding(CartioSpacing.md)
        .glassCard()
    }

    // MARK: - Stats

    private var statsSection: some View {
        HStack {
            statItem(value: "\(viewModel.cardCount)", label: "Cards")
            statItem(value: "\(viewModel.contactCount)", label: "Contacts")
            statItem(value: "\(viewModel.shareCount)", label: "Shares")
        }
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: CartioSpacing.xs) {
            Text(value)
                .font(CartioFonts.title3())
                .foregroundStyle(CartioColors.textPrimary)
            Text(label)
                .font(CartioFonts.caption())
                .foregroundStyle(CartioColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, CartioSpacing.md)
        .glassCard(cornerRadius: CartioRadius.button)
        .accessibilityElement(children: .combine)
    }

    // MARK: - Menu

    private var menuSection: some View {
        VStack(spacing: 0) {
            NavigationLink {
                AnalyticsDashboardView(viewModel: viewModel)
            } label: {
                menuRow(icon: "chart.bar", title: "Analytics")
            }
            Divider().padding(.leading, 44)
            NavigationLink {
                SubscriptionView(viewModel: viewModel)
            } label: {
                menuRow(icon: "crown", title: "Subscription")
            }
            Divider().padding(.leading, 44)
            NavigationLink {
                SettingsView(viewModel: viewModel)
            } label: {
                menuRow(icon: "gearshape", title: "Settings")
            }
            Divider().padding(.leading, 44)
            NavigationLink {
                ContactGroupsView(
                    contactInteractor: DependencyContainer.shared.makeContactInteractor(modelContext: modelContext)
                )
            } label: {
                menuRow(icon: "tag", title: "Contact Groups")
            }
        }
        .glassCard()
    }

    private func menuRow(icon: String, title: String) -> some View {
        HStack(spacing: CartioSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: CartioIconSize.lg))
                .foregroundStyle(CartioColors.primary)
                .frame(width: 28)
            Text(title)
                .font(CartioFonts.body())
                .foregroundStyle(CartioColors.textPrimary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, CartioSpacing.md)
        .padding(.vertical, CartioSpacing.sm + 4)
    }

    // MARK: - Support

    private var supportSection: some View {
        VStack(spacing: 0) {
            Button { requestReview() } label: {
                menuRow(icon: "star", title: "Rate Cartio")
            }
            Divider().padding(.leading, 44)
            if let appURL = URL(string: "https://apps.apple.com/app/cartio") {
                ShareLink(item: appURL) {
                    menuRow(icon: "square.and.arrow.up", title: "Share Cartio")
                }
            }
        }
        .glassCard()
    }

    // MARK: - Danger

    private var dangerSection: some View {
        Button(role: .destructive) {
            viewModel.signOut(router: router)
        } label: {
            HStack(spacing: CartioSpacing.sm) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .frame(width: 28)
                Text("Sign Out")
                    .font(CartioFonts.body())
                Spacer()
            }
            .foregroundStyle(CartioColors.error)
            .padding(.horizontal, CartioSpacing.md)
            .padding(.vertical, CartioSpacing.sm + 4)
        }
        .glassCard()
        .accessibilityHint("Signs you out of Cartio")
    }
}
