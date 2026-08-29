//
//  WelcomeView.swift
//  Cartio
//

import SwiftUI
import Lottie

struct WelcomeView: View {
    let viewModel: OnboardingViewModel
    @Environment(AppRouter.self) private var router
    @State private var showSignInAlert = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Logo + tagline
            VStack(spacing: CartioSpacing.sm) {
                Text("Cartio")
                    .font(CartioFonts.largeTitle())
                    .foregroundStyle(CartioColors.textPrimary)

                Text("Your Card. Everywhere.")
                    .font(CartioFonts.title3())
                    .foregroundStyle(CartioColors.textSecondary)
            }

            LottieView(name: "WelcomeAnimation", loopMode: .loop)
                .frame(maxWidth: 300, maxHeight: 300)
                .accessibilityHidden(true)

            Spacer()

            // Value props
            VStack(spacing: CartioSpacing.lg) {
                ValuePropRow(icon: "paintbrush.fill", text: "Design stunning cards in seconds")
                ValuePropRow(icon: "qrcode", text: "Share via QR, NFC, Link & AirDrop")
                ValuePropRow(icon: "chart.line.uptrend.xyaxis", text: "Track views and engagement")
            }
            .padding(.horizontal, CartioSpacing.lg)

            Spacer()

            // Bottom actions — pinned
            VStack(spacing: CartioSpacing.md) {
                Button("I already have an account") {
                    showSignInAlert = true
                }
                .font(CartioFonts.subheadline())
                .foregroundStyle(CartioColors.textSecondary)

                PrimaryButton(title: "Get Started") {
                    viewModel.nextPage()
                }
            }
            .padding(.horizontal, CartioSpacing.lg)
            .padding(.bottom, CartioSpacing.lg)
        }
        .alert("Welcome Back", isPresented: $showSignInAlert) {
            Button("Continue") {
                router.completeOnboarding()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Sign-in with Apple and Google will be available soon. Tap Continue to enter the app.")
        }
    }
}

// MARK: - Value Prop Row

private struct ValuePropRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: CartioSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: CartioIconSize.xl))
                .foregroundStyle(CartioColors.primary)
                .frame(width: 36, height: 36)
                .background(CartioColors.primary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: CartioRadius.input))

            Text(text)
                .font(CartioFonts.body())
                .foregroundStyle(CartioColors.textPrimary)

            Spacer()
        }
        .accessibilityElement(children: .combine)
    }
}
