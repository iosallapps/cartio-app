//
//  FeatureComparisonView.swift
//  Cartio
//
//  Shared feature comparison table used by PremiumPitchView, PaywallSheet, and SubscriptionView.
//

import SwiftUI

// MARK: - Feature Comparison Data

enum PremiumFeatures {
    /// The standard feature list shown in the onboarding pitch and paywall sheet.
    static let standard: [FeatureComparison] = [
        .text(feature: "Cards", free: "2", pro: "Unlimited"),
        .bool(feature: "QR / Link Sharing", free: true, pro: true),
        .bool(feature: "Basic Analytics", free: true, pro: true),
        .text(feature: "Templates", free: "8", pro: "20"),
        .bool(feature: "NFC Support", free: false, pro: true),
        .bool(feature: "Advanced Analytics", free: false, pro: true),
        .bool(feature: "Email Signatures", free: false, pro: true),
        .bool(feature: "Contact Export", free: false, pro: true)
    ]

    /// The detailed feature list shown on the subscription management screen.
    static let detailed: [FeatureComparison] = [
        .text(feature: "Unlimited cards", free: "2", pro: "Unlimited"),
        .text(feature: "All templates", free: "8", pro: "All"),
        .bool(feature: "NFC writing", free: false, pro: true),
        .bool(feature: "Basic Analytics", free: true, pro: true),
        .bool(feature: "Advanced Analytics", free: false, pro: true),
        .bool(feature: "Contact export", free: false, pro: true),
        .bool(feature: "Email signature", free: false, pro: true),
        .bool(feature: "Custom QR colors", free: false, pro: true),
        .text(feature: "Unlimited OCR scans", free: "10/mo", pro: "Unlimited")
    ]
}

// MARK: - Feature Comparison Model

enum FeatureComparison: Identifiable {
    case bool(feature: String, free: Bool, pro: Bool)
    case text(feature: String, free: String, pro: String)

    var id: String {
        switch self {
        case .bool(let feature, _, _): return feature
        case .text(let feature, _, _): return feature
        }
    }
}

// MARK: - Standard Feature Comparison View (used in PremiumPitchView & PaywallSheet)

struct FeatureComparisonView: View {
    var features: [FeatureComparison] = PremiumFeatures.standard

    var body: some View {
        VStack(spacing: CartioSpacing.sm) {
            ForEach(features) { feature in
                switch feature {
                case .bool(let name, let free, let pro):
                    FeatureRow(feature: name, free: free, pro: pro)
                case .text(let name, let free, let pro):
                    FeatureRow(feature: name, free: free, pro: pro)
                }
            }
        }
    }
}

// MARK: - Detailed Feature Comparison View (used in SubscriptionView)

struct DetailedFeatureComparisonView: View {
    var features: [FeatureComparison] = PremiumFeatures.detailed
    var title: String = "What you get with Pro"

    var body: some View {
        VStack(alignment: .leading, spacing: CartioSpacing.sm) {
            Text(title)
                .font(CartioFonts.headline())
                .foregroundStyle(CartioColors.textPrimary)

            ForEach(features) { feature in
                switch feature {
                case .bool(let name, let free, let pro):
                    detailedBoolRow(name, free: free, pro: pro)
                case .text(let name, let free, let pro):
                    detailedTextRow(name, free: free, pro: pro)
                }
            }
        }
        .padding(CartioSpacing.md)
        .background(CartioColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: CartioRadius.card))
    }

    private func detailedTextRow(_ feature: String, free: String, pro: String) -> some View {
        HStack {
            Text(feature)
                .font(CartioFonts.footnote())
                .foregroundStyle(CartioColors.textPrimary)
            Spacer()
            Text(free)
                .font(CartioFonts.caption())
                .foregroundStyle(CartioColors.textSecondary)
                .frame(width: 60)
            Text(pro)
                .font(CartioFonts.caption())
                .foregroundStyle(CartioColors.primary)
                .fontWeight(.semibold)
                .frame(width: 70)
        }
    }

    private func detailedBoolRow(_ feature: String, free: Bool, pro: Bool) -> some View {
        HStack {
            Text(feature)
                .font(CartioFonts.footnote())
                .foregroundStyle(CartioColors.textPrimary)
            Spacer()
            Image(systemName: free ? "checkmark" : "xmark")
                .font(.system(size: 11))
                .foregroundStyle(free ? CartioColors.success : CartioColors.textSecondary)
                .frame(width: 60)
            Image(systemName: pro ? "checkmark" : "xmark")
                .font(.system(size: 11))
                .foregroundStyle(pro ? CartioColors.success : CartioColors.textSecondary)
                .frame(width: 70)
        }
    }
}
