//
//  TemplatePickerView.swift
//  Cartio
//

import SwiftUI

struct TemplatePickerView: View {
    let templates: [CardTemplate]
    @Binding var selected: CardTemplate
    var previewName: String = ""
    var previewTitle: String = ""
    var previewCompany: String = ""

    private var groupedTemplates: [(CardTemplate.TemplateCategory, [CardTemplate])] {
        CardTemplate.TemplateCategory.allCases.compactMap { category in
            let filtered = templates.filter { $0.category == category }
            return filtered.isEmpty ? nil : (category, filtered)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: CartioSpacing.md) {
            ForEach(groupedTemplates, id: \.0) { category, categoryTemplates in
                categorySection(category, templates: categoryTemplates)
            }
        }
    }

    private func categorySection(
        _ category: CardTemplate.TemplateCategory,
        templates: [CardTemplate]
    ) -> some View {
        VStack(alignment: .leading, spacing: CartioSpacing.xs) {
            Text(category.displayName)
                .font(CartioFonts.caption())
                .foregroundStyle(CartioColors.textSecondary)
                .padding(.horizontal, CartioSpacing.md)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: CartioSpacing.sm) {
                    ForEach(templates) { template in
                        templateThumbnail(template)
                    }
                }
                .padding(.horizontal, CartioSpacing.md)
            }
        }
    }

    private func templateThumbnail(_ template: CardTemplate) -> some View {
        let isSelected = selected.id == template.id

        return VStack(spacing: CartioSpacing.xs) {
            ZStack(alignment: .topTrailing) {
                // Color swatch showing layout hint
                RoundedRectangle(cornerRadius: CartioRadius.input)
                    .fill(Color(hex: template.backgroundColor))
                    .frame(width: 90, height: 56)
                    .overlay {
                        layoutHint(template)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: CartioRadius.input))
                    .overlay(
                        RoundedRectangle(cornerRadius: CartioRadius.input)
                            .stroke(isSelected ? CartioColors.primary : .clear, lineWidth: 2)
                    )

                if template.isPremium {
                    Image(systemName: "lock.fill")
                        .font(.system(size: CartioIconSize.xs))
                        .foregroundStyle(CartioColors.background)
                        .padding(2.5)
                        .background(CartioColors.secondary)
                        .clipShape(Circle())
                        .offset(x: -3, y: 3)
                }
            }

            Text(template.name)
                .font(CartioFonts.caption())
                .foregroundStyle(isSelected ? CartioColors.primary : CartioColors.textSecondary)
                .lineLimit(1)
        }
        .onTapGesture {
            Haptics.selection()
            selected = template
        }
        .accessibilityLabel("\(template.name) template\(template.isPremium ? ", premium" : "")")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: - Layout Hint

    /// Simplified visual hint of the layout style inside the thumbnail.
    @ViewBuilder
    private func layoutHint(_ template: CardTemplate) -> some View {
        let text = Color(hex: template.textColor)
        let accent = Color(hex: template.accentColor)

        switch template.layoutStyle {
        case .standard:
            VStack(alignment: .leading, spacing: 3) {
                Circle().fill(accent).frame(width: 10, height: 10)
                RoundedRectangle(cornerRadius: 1).fill(text).frame(width: 36, height: 4)
                RoundedRectangle(cornerRadius: 1).fill(text.opacity(0.5)).frame(width: 24, height: 3)
                Spacer(minLength: 0)
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityHidden(true)

        case .banner:
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 2).fill(accent)
                    .frame(height: 14)
                    .padding(.horizontal, 6).padding(.top, 6)
                    .overlay(alignment: .bottomLeading) {
                        RoundedRectangle(cornerRadius: 1).fill(.white).frame(width: 26, height: 3)
                            .padding(.leading, 10).padding(.bottom, 2)
                    }
                VStack(alignment: .leading, spacing: 2) {
                    RoundedRectangle(cornerRadius: 1).fill(text.opacity(0.5)).frame(width: 20, height: 3)
                    RoundedRectangle(cornerRadius: 1).fill(text.opacity(0.3)).frame(width: 16, height: 3)
                }
                .padding(.horizontal, 8).padding(.top, 4)
                Spacer(minLength: 0)
            }
            .accessibilityHidden(true)

        case .split:
            HStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 2).fill(accent)
                    .frame(width: 24)
                    .overlay {
                        Circle().fill(.white.opacity(0.3)).frame(width: 12, height: 12)
                    }
                VStack(alignment: .leading, spacing: 2) {
                    RoundedRectangle(cornerRadius: 1).fill(text).frame(width: 30, height: 4)
                    RoundedRectangle(cornerRadius: 1).fill(text.opacity(0.5)).frame(width: 20, height: 3)
                }
                Spacer(minLength: 0)
            }
            .padding(6)
            .accessibilityHidden(true)

        case .compact:
            HStack(spacing: 4) {
                Circle().fill(accent).frame(width: 12, height: 12)
                VStack(alignment: .leading, spacing: 2) {
                    RoundedRectangle(cornerRadius: 1).fill(text).frame(width: 28, height: 4)
                    RoundedRectangle(cornerRadius: 1).fill(text.opacity(0.5)).frame(width: 18, height: 3)
                }
                Spacer(minLength: 0)
            }
            .padding(8)
            .accessibilityHidden(true)

        case .centered:
            VStack(spacing: 3) {
                Spacer(minLength: 0)
                RoundedRectangle(cornerRadius: 1).fill(text).frame(width: 36, height: 5)
                RoundedRectangle(cornerRadius: 1).fill(text.opacity(0.5)).frame(width: 24, height: 3)
                RoundedRectangle(cornerRadius: 1).fill(accent.opacity(0.6)).frame(width: 16, height: 2)
                Spacer(minLength: 0)
            }
            .accessibilityHidden(true)

        case .sidebar:
            HStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 1).fill(accent)
                    .frame(width: 3)
                VStack(alignment: .leading, spacing: 2) {
                    RoundedRectangle(cornerRadius: 1).fill(text).frame(width: 30, height: 4)
                    RoundedRectangle(cornerRadius: 1).fill(text.opacity(0.5)).frame(width: 20, height: 3)
                    Spacer(minLength: 0)
                    Rectangle().fill(accent.opacity(0.3)).frame(height: 0.5)
                    RoundedRectangle(cornerRadius: 1).fill(text.opacity(0.3)).frame(width: 24, height: 2)
                }
                Spacer(minLength: 0)
            }
            .padding(6)
            .accessibilityHidden(true)

        case .topHeavy:
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    RoundedRectangle(cornerRadius: 1).fill(text).frame(width: 36, height: 5)
                    RoundedRectangle(cornerRadius: 1).fill(accent).frame(width: 20, height: 3)
                }
                .padding(.horizontal, 8).padding(.top, 8)
                Spacer(minLength: 0)
                RoundedRectangle(cornerRadius: 2).fill(accent)
                    .frame(height: 10)
                    .padding(.horizontal, 6).padding(.bottom, 6)
            }
            .accessibilityHidden(true)

        case .divided:
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    RoundedRectangle(cornerRadius: 1).fill(text).frame(width: 32, height: 4)
                    RoundedRectangle(cornerRadius: 1).fill(text.opacity(0.5)).frame(width: 20, height: 3)
                }
                .padding(.horizontal, 8).padding(.top, 8)
                Spacer(minLength: 0)
                Rectangle().fill(accent).frame(height: 1.5).padding(.horizontal, 8)
                Spacer(minLength: 0)
                VStack(alignment: .leading, spacing: 2) {
                    RoundedRectangle(cornerRadius: 1).fill(text.opacity(0.3)).frame(width: 24, height: 2)
                }
                .padding(.horizontal, 8).padding(.bottom, 8)
            }
            .accessibilityHidden(true)

        case .bordered:
            RoundedRectangle(cornerRadius: 4)
                .strokeBorder(accent, lineWidth: 1)
                .padding(6)
                .overlay {
                    VStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 1).fill(text).frame(width: 28, height: 4)
                        RoundedRectangle(cornerRadius: 1).fill(text.opacity(0.5)).frame(width: 18, height: 3)
                    }
                }
                .accessibilityHidden(true)

        case .minimal:
            VStack(spacing: 3) {
                Spacer(minLength: 0)
                RoundedRectangle(cornerRadius: 1).fill(text).frame(width: 32, height: 4)
                RoundedRectangle(cornerRadius: 1).fill(text.opacity(0.4)).frame(width: 20, height: 3)
                Spacer(minLength: 0)
            }
            .accessibilityHidden(true)
        }
    }
}
