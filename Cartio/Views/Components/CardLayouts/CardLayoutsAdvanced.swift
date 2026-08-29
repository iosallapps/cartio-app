//
//  CardLayoutsAdvanced.swift
//  Cartio
//
//  Advanced card layouts: split, banner, sidebar, topHeavy, bordered.
//

import SwiftUI

extension CardPreviewComponent {

    // MARK: - Split Layout

    /// Two-column: left accent panel with initials, right info stack.
    var splitLayout: some View {
        HStack(spacing: 0) {
            // Left accent panel
            Color(hex: template.accentColor)
                .frame(width: 80)
                .overlay {
                    Text(initialsText)
                        .font(CartioFonts.title3())
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(.white.opacity(0.2))
                        .clipShape(Circle())
                }

            // Right info panel
            VStack(alignment: .leading, spacing: CartioSpacing.xs) {
                Text(name.isEmpty ? "Your Name" : name)
                    .font(CartioFonts.title3())
                    .foregroundStyle(Color(hex: template.textColor))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                if !title.isEmpty {
                    Text(title)
                        .font(CartioFonts.subheadline())
                        .foregroundStyle(Color(hex: template.textColor).opacity(0.7))
                        .lineLimit(1)
                }

                if !company.isEmpty {
                    Text(company)
                        .font(CartioFonts.subheadline())
                        .foregroundStyle(Color(hex: template.accentColor))
                        .lineLimit(1)
                }

                Spacer(minLength: 0)

                if !isThumbnail {
                    contactRow
                }
            }
            .padding(CartioSpacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Banner Layout

    /// Top accent band with large name, info below on background color.
    var bannerLayout: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top banner
            ZStack(alignment: .bottomLeading) {
                Color(hex: template.accentColor)
                    .frame(height: 52)

                Text(name.isEmpty ? "Your Name" : name)
                    .font(CartioFonts.title2())
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, CartioSpacing.md)
                    .padding(.bottom, CartioSpacing.xs)
            }

            // Content below banner
            VStack(alignment: .leading, spacing: CartioSpacing.xs) {
                if !title.isEmpty {
                    Text(title)
                        .font(CartioFonts.callout())
                        .foregroundStyle(Color(hex: template.textColor).opacity(0.7))
                        .lineLimit(1)
                }

                if !company.isEmpty {
                    Text(company)
                        .font(CartioFonts.callout())
                        .foregroundStyle(Color(hex: template.textColor))
                        .lineLimit(1)
                }

                Spacer(minLength: 0)

                if !isThumbnail {
                    contactRow
                    if !activeSocialLinks.isEmpty { socialIconsRow }
                }
            }
            .padding(CartioSpacing.md)
        }
    }

    // MARK: - Sidebar Layout

    /// 4pt vertical accent bar on left edge, content right with divider.
    var sidebarLayout: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(Color(hex: template.accentColor))
                .frame(width: 4)

            VStack(alignment: .leading, spacing: CartioSpacing.xs) {
                Text(name.isEmpty ? "Your Name" : name)
                    .font(CartioFonts.headline())
                    .foregroundStyle(Color(hex: template.textColor))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                if !title.isEmpty {
                    Text(title)
                        .font(CartioFonts.footnote())
                        .foregroundStyle(Color(hex: template.textColor).opacity(0.7))
                        .lineLimit(1)
                }

                if !company.isEmpty {
                    Text(company)
                        .font(CartioFonts.footnote())
                        .foregroundStyle(Color(hex: template.accentColor))
                        .lineLimit(1)
                }

                if !isThumbnail {
                    Divider()
                        .background(Color(hex: template.accentColor).opacity(0.3))

                    contactRow

                    if !activeSocialLinks.isEmpty { socialIconsRow }
                }

                Spacer(minLength: 0)
            }
            .padding(.leading, CartioSpacing.md)
            .padding(.vertical, CartioSpacing.md)
            .padding(.trailing, CartioSpacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Top Heavy Layout

    /// Large name at top, accent footer bar with contact info.
    var topHeavyLayout: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: CartioSpacing.xs) {
                Text(name.isEmpty ? "Your Name" : name)
                    .font(CartioFonts.title2())
                    .foregroundStyle(Color(hex: template.textColor))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                if !title.isEmpty {
                    Text(title)
                        .font(CartioFonts.callout())
                        .foregroundStyle(Color(hex: template.accentColor))
                        .lineLimit(1)
                }

                if !company.isEmpty {
                    Text(company)
                        .font(CartioFonts.callout())
                        .foregroundStyle(Color(hex: template.textColor).opacity(0.7))
                        .lineLimit(1)
                }
            }
            .padding(CartioSpacing.md)

            Spacer(minLength: 0)

            if !isThumbnail {
                // Footer bar
                HStack(spacing: CartioSpacing.md) {
                    if !email.isEmpty {
                        Label {
                            Text(email).lineLimit(1)
                        } icon: {
                            Image(systemName: "envelope")
                        }
                        .font(CartioFonts.caption())
                    }
                    Spacer(minLength: 0)
                    if !phone.isEmpty {
                        Label {
                            Text(phone).lineLimit(1)
                        } icon: {
                            Image(systemName: "phone")
                        }
                        .font(CartioFonts.caption())
                    }
                }
                .foregroundStyle(.white)
                .padding(.horizontal, CartioSpacing.md)
                .padding(.vertical, CartioSpacing.sm)
                .background(Color(hex: template.accentColor))
            }
        }
    }

    // MARK: - Bordered Layout

    /// Inset accent border frame, centered content, text initials.
    var borderedLayout: some View {
        VStack(spacing: CartioSpacing.sm) {
            Spacer(minLength: 0)

            Text(initialsText)
                .font(CartioFonts.title3())
                .foregroundStyle(Color(hex: template.accentColor))

            Text(name.isEmpty ? "Your Name" : name)
                .font(CartioFonts.title3())
                .foregroundStyle(Color(hex: template.textColor))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            if !title.isEmpty {
                Text(title)
                    .font(CartioFonts.subheadline())
                    .foregroundStyle(Color(hex: template.textColor).opacity(0.7))
                    .lineLimit(1)
            }

            if !company.isEmpty {
                Text(company)
                    .font(CartioFonts.subheadline())
                    .foregroundStyle(Color(hex: template.accentColor))
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            if !isThumbnail {
                contactRow
            }
        }
        .padding(CartioSpacing.md)
        .frame(maxWidth: .infinity)
        .overlay(
            RoundedRectangle(cornerRadius: CartioRadius.input)
                .strokeBorder(Color(hex: template.accentColor), lineWidth: 2)
                .padding(CartioSpacing.sm)
        )
    }

    // MARK: - Helpers

    var initialsText: String {
        name.components(separatedBy: " ")
            .prefix(2)
            .compactMap { $0.first.map(String.init) }
            .joined()
            .isEmpty ? "?" : name.components(separatedBy: " ")
            .prefix(2)
            .compactMap { $0.first.map(String.init) }
            .joined()
    }
}
