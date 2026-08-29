//
//  PaywallSheet.swift
//  Cartio
//
//  Reusable paywall presented when a gated feature is tapped.
//

import SwiftUI
import StoreKit

struct PaywallSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: String = AppConstants.Products.proYearly
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage: String?

    private let subscriptionInteractor = DependencyContainer.shared.makeSubscriptionInteractor()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CartioSpacing.sm) {
                    headerSection

                    FeatureComparisonView()

                    PricingCardsView(selectedPlan: $selectedPlan)

                    trustSignals
                        .padding(.bottom, CartioSpacing.sm)
                }
                .padding(.horizontal, CartioSpacing.lg)
                .padding(.vertical, CartioSpacing.md)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(CartioColors.textSecondary)
                            .font(.system(size: CartioIconSize.xl))
                    }
                    .accessibilityLabel("Close")
                }
            }
        }
        .presentationDetents([.large])
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: CartioSpacing.sm) {
            Image(systemName: "crown.fill")
                .font(.system(size: CartioIconSize.hero))
                .foregroundStyle(CartioColors.warning)
                .accessibilityHidden(true)

            Text("Unlock the full\nCartio experience")
                .font(CartioFonts.title())
                .foregroundStyle(CartioColors.textPrimary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, CartioSpacing.sm)
    }

    // MARK: - Trust Signals

    private var trustSignals: some View {
        VStack(spacing: CartioSpacing.md) {
            TrustSignalsView {
                Task {
                    try? await subscriptionInteractor.restorePurchases()
                    dismiss()
                }
            }

            PrimaryButton(
                title: PricingPlans.ctaTitle(for: selectedPlan),
                isLoading: isPurchasing
            ) {
                Task { await purchaseSelectedPlan() }
            }
        }
        .alert("Purchase Error", isPresented: $showError) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "Something went wrong.")
        }
    }

    // MARK: - Purchase

    private func purchaseSelectedPlan() async {
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let products = try await subscriptionInteractor.fetchProducts()
            guard let product = products.first(where: { $0.id == selectedPlan }) else {
                errorMessage = "Product not found."
                showError = true
                return
            }
            try await subscriptionInteractor.purchase(product)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
