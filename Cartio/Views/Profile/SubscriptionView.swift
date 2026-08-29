//
//  SubscriptionView.swift
//  Cartio
//

import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @State var viewModel: ProfileViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: CartioSpacing.lg) {
                currentPlanSection

                if !viewModel.isPremium {
                    DetailedFeatureComparisonView()
                    upgradeSection
                }

                CompactTrustSignalsView {
                    Task { await viewModel.restorePurchases() }
                }
            }
            .sectionPadding()
            .padding(.bottom, CartioSpacing.xl)
        }
        .navigationTitle("Subscription")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.fetchProducts() }
    }

    // MARK: - Current Plan

    private var currentPlanSection: some View {
        VStack(spacing: CartioSpacing.sm) {
            Image(systemName: viewModel.isPremium ? "crown.fill" : "person.circle")
                .font(.system(size: CartioIconSize.hero))
                .foregroundStyle(viewModel.isPremium ? CartioColors.warning : CartioColors.primary)

            Text(viewModel.isPremium ? "Pro Plan" : "Free Plan")
                .font(CartioFonts.title3())
                .foregroundStyle(CartioColors.textPrimary)

            Text(viewModel.isPremium ? "You have access to all features" : "Upgrade to unlock all features")
                .font(CartioFonts.subheadline())
                .foregroundStyle(CartioColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(CartioSpacing.lg)
        .background(CartioColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: CartioRadius.card))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            viewModel.isPremium
                ? "Current plan: Pro. You have access to all features"
                : "Current plan: Free. Upgrade to unlock all features"
        )
    }

    // MARK: - Upgrade

    private var upgradeSection: some View {
        VStack(spacing: CartioSpacing.md) {
            ForEach(sortedProducts, id: \.id) { product in
                productRow(product, isHighlighted: product.id == AppConstants.Products.proYearly)
            }
        }
    }

    private var sortedProducts: [Product] {
        viewModel.products.sorted { first, second in
            let order = [
                AppConstants.Products.proMonthly,
                AppConstants.Products.proYearly,
                AppConstants.Products.proLifetime
            ]
            let firstIndex = order.firstIndex(of: first.id) ?? 99
            let secondIndex = order.firstIndex(of: second.id) ?? 99
            return firstIndex < secondIndex
        }
    }

    private func productRow(_ product: Product, isHighlighted: Bool) -> some View {
        Button {
            Task { await viewModel.purchase(product) }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: CartioSpacing.xs) {
                    HStack {
                        Text(product.displayName)
                            .font(CartioFonts.body())
                            .foregroundStyle(CartioColors.textPrimary)
                        if isHighlighted {
                            Text("BEST VALUE")
                                .font(CartioFonts.caption())
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(CartioColors.success)
                                .clipShape(Capsule())
                                .accessibilityHidden(true)
                        }
                    }
                    Text(product.description)
                        .font(CartioFonts.caption())
                        .foregroundStyle(CartioColors.textSecondary)
                }

                Spacer()

                Text(product.displayPrice)
                    .font(CartioFonts.headline())
                    .foregroundStyle(CartioColors.primary)
            }
            .padding(CartioSpacing.md)
            .background(isHighlighted ? CartioColors.primary.opacity(0.08) : CartioColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: CartioRadius.button))
            .overlay(
                RoundedRectangle(cornerRadius: CartioRadius.button)
                    .stroke(isHighlighted ? CartioColors.primary : .clear, lineWidth: 1.5)
            )
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(product.displayName)\(isHighlighted ? ", best value" : ""), \(product.displayPrice)"
        )
    }
}
