//
//  ErrorView.swift
//  Cartio
//

import SwiftUI

struct ErrorView: View {
    let message: String
    var retryAction: (() -> Void)?

    var body: some View {
        VStack(spacing: CartioSpacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundStyle(CartioColors.error)

            Text(message)
                .font(CartioFonts.subheadline())
                .foregroundStyle(CartioColors.textSecondary)
                .multilineTextAlignment(.center)

            if let retryAction {
                SecondaryButton(title: "Retry", action: retryAction)
                    .frame(maxWidth: 150)
            }
        }
        .padding(CartioSpacing.xl)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Error: \(message)")
    }
}
