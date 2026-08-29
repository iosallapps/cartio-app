//
//  ToastView.swift
//  Cartio
//

import SwiftUI
import UIKit

struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(CartioFonts.subheadline())
            .foregroundStyle(CartioColors.textPrimary)
            .padding(.horizontal, CartioSpacing.lg)
            .padding(.vertical, CartioSpacing.sm)
            .background(Color(.systemGray6)) // Adaptive dark surface — works in both light and dark mode
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
            .onAppear {
                UIAccessibility.post(notification: .announcement, argument: message)
            }
    }
}
