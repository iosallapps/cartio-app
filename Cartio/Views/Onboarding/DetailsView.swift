//
//  DetailsView.swift
//  Cartio
//

import SwiftUI

struct DetailsView: View {
    @Bindable var viewModel: OnboardingViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shakeNameField = false
    @State private var showNameHint = false

    var body: some View {
        VStack(spacing: 0) {
            // Card preview — fixed height, below page control
            CardPreviewComponent(
                name: viewModel.name.isEmpty ? "Your Name" : viewModel.name,
                title: viewModel.title.isEmpty ? "Your Title" : viewModel.title,
                company: viewModel.company,
                email: viewModel.email,
                phone: viewModel.phone,
                template: .classic
            )
            .cardShadow()
            .padding(.horizontal, CartioSpacing.lg)
            .padding(.top, CartioSpacing.lg)
            .frame(height: 200)
            .accessibilityLabel("Card preview showing your details as you type")

            // Scrollable form area
            ScrollView {
                // Heading
                Text("Create your first card")
                    .font(CartioFonts.title3())
                    .foregroundStyle(CartioColors.textPrimary)
                    .padding(.top, CartioSpacing.lg)

                // Form fields
                VStack(spacing: CartioSpacing.sm) {
                    VStack(alignment: .leading, spacing: CartioSpacing.xs) {
                        TextField("Full Name *", text: $viewModel.name)
                            .offset(x: shakeNameField ? -8 : 0)
                            .reduceMotionAnimation(
                                shakeNameField
                                    ? .default.repeatCount(3, autoreverses: true).speed(6)
                                    : .default,
                                value: shakeNameField
                            )

                        if showNameHint {
                            Text("Name is required to create your card")
                                .font(CartioFonts.caption())
                                .foregroundStyle(CartioColors.error)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }

                    TextField("Title / Role", text: $viewModel.title)
                    TextField("Company", text: $viewModel.company)
                    TextField("Email", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                    TextField("Phone", text: $viewModel.phone)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                }
                .textFieldStyle(CartioTextFieldStyle())
                .padding(.horizontal, CartioSpacing.lg)
                .padding(.top, CartioSpacing.md)
            }
            .scrollDismissesKeyboard(.interactively)

            // Bottom actions — pinned
            VStack(spacing: CartioSpacing.md) {
                Button("Skip for now") {
                    viewModel.skipCardCreation()
                }
                .font(CartioFonts.subheadline())
                .foregroundStyle(CartioColors.textSecondary)
                .accessibilityHint("Skips card creation and enters the app")

                PrimaryButton(title: "Create My Card", isLoading: viewModel.isCreatingCard) {
                    if viewModel.isNameValid {
                        Task { await viewModel.createFirstCard() }
                    } else {
                        Haptics.error()
                        if reduceMotion {
                            showNameHint = true
                        } else {
                            shakeNameField = true
                            withAnimation { showNameHint = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                shakeNameField = false
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, CartioSpacing.lg)
            .padding(.bottom, CartioSpacing.lg)
        }
        .onChange(of: viewModel.name) {
            if viewModel.isNameValid && showNameHint {
                if reduceMotion {
                    showNameHint = false
                } else {
                    withAnimation { showNameHint = false }
                }
            }
        }
    }
}
