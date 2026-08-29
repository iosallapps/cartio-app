//
//  QRFullscreenView.swift
//  Cartio
//

import SwiftUI
import UIKit

struct QRFullscreenView: View {
    let qrImage: UIImage
    let name: String
    let title: String?
    @Environment(\.dismiss) private var dismiss
    @State private var previousBrightness: CGFloat = 0.5

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea() // Intentional: white background required for QR scanning

            VStack(spacing: CartioSpacing.lg) {
                Image(uiImage: qrImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 300, maxHeight: 300)

                Text(name)
                    .font(CartioFonts.title2())
                    .foregroundStyle(CartioColors.textPrimary)

                if let title, !title.isEmpty {
                    Text(title)
                        .font(CartioFonts.subheadline())
                        .foregroundStyle(CartioColors.textSecondary)
                }

                Text("Tap anywhere to close")
                    .font(CartioFonts.caption())
                    .foregroundStyle(CartioColors.textSecondary.opacity(0.6))
                    .padding(.top, CartioSpacing.lg)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityLabel("QR code for \(name)\(title != nil && !title!.isEmpty ? ", \(title!)" : ""). Tap anywhere to dismiss.")
        .onTapGesture { dismiss() }
        .onAppear {
            if let screen = currentScreen {
                previousBrightness = screen.brightness
                screen.brightness = 1.0
            }
        }
        .onDisappear {
            currentScreen?.brightness = previousBrightness
        }
    }

    private var currentScreen: UIScreen? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.screen
    }
}
