//
//  ColorPickerComponent.swift
//  Cartio
//

import SwiftUI

struct ColorPickerComponent: View {
    @Binding var selectedColorHex: String
    @State private var showCustomInput = false
    @State private var customHex = ""

    private let presetColors: [(name: String, hex: String)] = [
        ("Black", "#000000"),
        ("Teal", "#0A7E8C"),
        ("Navy", "#1E3A5F"),
        ("Burgundy", "#8B1A4A"),
        ("Forest", "#2D5016"),
        ("Purple", "#6B21A8"),
        ("Coral", "#FF6B6B"),
        ("Charcoal", "#374151")
    ]

    var body: some View {
        VStack(spacing: CartioSpacing.sm) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CartioSpacing.sm) {
                    ForEach(presetColors, id: \.hex) { preset in
                        Button {
                            selectedColorHex = preset.hex
                            showCustomInput = false
                        } label: {
                            Circle()
                                .fill(Color(hex: preset.hex))
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Circle()
                                        .strokeBorder(
                                    CartioColors.primary,
                                    lineWidth: selectedColorHex == preset.hex ? 3 : 0
                                )
                                )
                                .overlay(
                                    Circle()
                                        .strokeBorder(
                                            CartioColors.background,
                                            lineWidth: selectedColorHex == preset.hex ? 1.5 : 0
                                        )
                                        .padding(2)
                                )
                        }
                        .accessibilityLabel("\(preset.name) color")
                        .accessibilityAddTraits(selectedColorHex == preset.hex ? .isSelected : [])
                    }

                    Button {
                        showCustomInput.toggle()
                        if showCustomInput {
                            customHex = selectedColorHex
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(CartioColors.surface)
                                .frame(width: 36, height: 36)

                            Image(systemName: "eyedropper")
                                .font(.system(size: CartioIconSize.md, weight: .semibold))
                                .foregroundStyle(CartioColors.textPrimary)

                            if showCustomInput {
                                Circle()
                                    .strokeBorder(CartioColors.primary, lineWidth: 3)
                                    .frame(width: 36, height: 36)
                            }
                        }
                    }
                    .accessibilityLabel("Custom color")
                    .accessibilityHint("Enter a hex color code")
                }
            }

            if showCustomInput {
                HStack(spacing: CartioSpacing.sm) {
                    Text("#")
                        .font(CartioFonts.body())
                        .foregroundStyle(CartioColors.textSecondary)

                    TextField("Hex code", text: $customHex)
                        .font(CartioFonts.body())
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .frame(maxWidth: 120)
                        .onChange(of: customHex) { _, newValue in
                            let cleaned = newValue.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
                            if cleaned.count == 6 || cleaned.count == 3 {
                                selectedColorHex = "#\(cleaned)"
                            }
                        }

                    Circle()
                        .fill(Color(hex: customHex))
                        .frame(width: 24, height: 24)
                        .accessibilityHidden(true)
                }
                .padding(CartioSpacing.sm)
                .background(CartioColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: CartioRadius.input))
            }
        }
    }
}
