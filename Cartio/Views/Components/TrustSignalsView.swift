//
//  TrustSignalsView.swift
//  Cartio
//
//  Shared trust signals footer with restore purchases, used by PremiumPitchView and PaywallSheet.
//

import SwiftUI

// MARK: - Standard Trust Signals (restore inline with text)

struct TrustSignalsView: View {
    var onRestore: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text("Cancel anytime · No commitment ·")
                .font(CartioFonts.caption())
                .foregroundStyle(CartioColors.textSecondary)
            Button("Restore") {
                onRestore()
            }
            .font(CartioFonts.caption())
            .foregroundStyle(CartioColors.primary)
        }
    }
}

// MARK: - Compact Trust Signals (used in SubscriptionView)

struct CompactTrustSignalsView: View {
    var onRestore: () -> Void

    var body: some View {
        VStack(spacing: CartioSpacing.sm) {
            Button {
                onRestore()
            } label: {
                Text("Restore Purchases")
                    .font(CartioFonts.subheadline())
                    .foregroundStyle(CartioColors.primary)
            }

            Text("Cancel anytime • Secure with Apple")
                .font(CartioFonts.caption())
                .foregroundStyle(CartioColors.textSecondary)
        }
    }
}
