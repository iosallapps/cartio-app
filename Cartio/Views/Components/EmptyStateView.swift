//
//  EmptyStateView.swift
//  Cartio
//

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var buttonTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: CartioSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(CartioColors.textSecondary.opacity(0.5))

            Text(title)
                .font(CartioFonts.title3())
                .foregroundStyle(CartioColors.textPrimary)

            Text(message)
                .font(CartioFonts.subheadline())
                .foregroundStyle(CartioColors.textSecondary)
                .multilineTextAlignment(.center)

            if let buttonTitle, let action {
                PrimaryButton(title: buttonTitle, action: action)
                    .frame(maxWidth: 200)
            }
        }
        .padding(CartioSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(message)")
    }
}
