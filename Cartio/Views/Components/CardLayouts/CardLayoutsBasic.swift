//
//  CardLayoutsBasic.swift
//  Cartio
//
//  Basic card layouts: standard, minimal, compact, centered, divided.
//

import SwiftUI

extension CardPreviewComponent {

    // MARK: - Standard Layout

    /// Current layout — initials circle, vertical stack, contact at bottom.
    var standardLayout: some View {
        VStack(alignment: template.alignment == .center ? .center : .leading, spacing: CartioSpacing.xs) {
            if !isThumbnail { initialsCircle }

            Text(name.isEmpty ? "Your Name" : name)
                .font(CartioFonts.headline())
                .foregroundStyle(Color(hex: template.textColor))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            if !title.isEmpty {
                Text(title)
                    .font(CartioFonts.caption())
                    .foregroundStyle(Color(hex: template.textColor).opacity(0.7))
                    .lineLimit(1)
            }

            if !company.isEmpty {
                Text(company)
                    .font(CartioFonts.caption())
                    .foregroundStyle(Color(hex: template.accentColor))
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            if !isThumbnail {
                contactRow
                if !activeSocialLinks.isEmpty { socialIconsRow }
            }
        }
        .padding(CartioSpacing.md)
        .frame(maxWidth: .infinity, alignment: template.alignment == .center ? .center : .leading)
    }

    // MARK: - Minimal Layout

    /// Name + title only. No initials, no contact, no social. Maximum whitespace.
    var minimalLayout: some View {
        VStack(spacing: CartioSpacing.sm) {
            Spacer(minLength: 0)

            Text(name.isEmpty ? "Your Name" : name)
                .font(CartioFonts.headline())
                .foregroundStyle(Color(hex: template.textColor))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            if !title.isEmpty {
                Text(title)
                    .font(CartioFonts.footnote())
                    .foregroundStyle(Color(hex: template.textColor).opacity(0.6))
                    .lineLimit(1)
            }

            if !company.isEmpty {
                Text(company)
                    .font(CartioFonts.footnote())
                    .foregroundStyle(Color(hex: template.accentColor).opacity(0.8))
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(CartioSpacing.lg)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Compact Layout

    /// Horizontal: initials left, name+title center, contact icons right.
    var compactLayout: some View {
        HStack(spacing: CartioSpacing.md) {
            initialsCircle

            VStack(alignment: .leading, spacing: CartioSpacing.xs) {
                Text(name.isEmpty ? "Your Name" : name)
                    .font(CartioFonts.headline())
                    .foregroundStyle(Color(hex: template.textColor))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                if !title.isEmpty {
                    Text(title)
                        .font(CartioFonts.caption())
                        .foregroundStyle(Color(hex: template.textColor).opacity(0.7))
                        .lineLimit(1)
                }

                if !company.isEmpty {
                    Text(company)
                        .font(CartioFonts.caption())
                        .foregroundStyle(Color(hex: template.accentColor))
                        .lineLimit(1)
                }
            }
            .layoutPriority(1)

            Spacer(minLength: 0)

            if !isThumbnail {
                VStack(spacing: CartioSpacing.xs) {
                    if !email.isEmpty {
                        Image(systemName: "envelope")
                            .font(.system(size: 12))
                            .foregroundStyle(Color(hex: template.accentColor))
                    }
                    if !phone.isEmpty {
                        Image(systemName: "phone")
                            .font(.system(size: 12))
                            .foregroundStyle(Color(hex: template.accentColor))
                    }
                    if !website.isEmpty {
                        Image(systemName: "globe")
                            .font(.system(size: 12))
                            .foregroundStyle(Color(hex: template.accentColor))
                    }
                }
            }
        }
        .padding(CartioSpacing.md)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Centered Layout

    /// No initials. Large centered name, small details below, icon-only contact.
    var centeredLayout: some View {
        VStack(spacing: CartioSpacing.sm) {
            Spacer(minLength: 0)

            Text(name.isEmpty ? "Your Name" : name)
                .font(CartioFonts.title())
                .foregroundStyle(Color(hex: template.textColor))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .multilineTextAlignment(.center)

            if !title.isEmpty {
                Text(title)
                    .font(CartioFonts.subheadline())
                    .foregroundStyle(Color(hex: template.textColor).opacity(0.7))
                    .lineLimit(1)
            }

            if !company.isEmpty {
                Text(company.uppercased())
                    .font(CartioFonts.caption())
                    .tracking(1.5)
                    .foregroundStyle(Color(hex: template.accentColor))
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            if !isThumbnail {
                HStack(spacing: CartioSpacing.lg) {
                    if !email.isEmpty {
                        Image(systemName: "envelope")
                            .font(.system(size: 14))
                            .foregroundStyle(Color(hex: template.accentColor))
                    }
                    if !phone.isEmpty {
                        Image(systemName: "phone")
                            .font(.system(size: 14))
                            .foregroundStyle(Color(hex: template.accentColor))
                    }
                    if !website.isEmpty {
                        Image(systemName: "globe")
                            .font(.system(size: 14))
                            .foregroundStyle(Color(hex: template.accentColor))
                    }
                }
            }
        }
        .padding(CartioSpacing.md)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Divided Layout

    /// Horizontal accent divider at center. Name above, contact below.
    var dividedLayout: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: CartioSpacing.xs) {
                Text(name.isEmpty ? "Your Name" : name)
                    .font(CartioFonts.title3())
                    .foregroundStyle(Color(hex: template.textColor))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                if !title.isEmpty {
                    Text(title)
                        .font(CartioFonts.callout())
                        .foregroundStyle(Color(hex: template.textColor).opacity(0.7))
                        .lineLimit(1)
                }

                if !company.isEmpty {
                    Text(company)
                        .font(CartioFonts.callout())
                        .foregroundStyle(Color(hex: template.accentColor))
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 0)

            Rectangle()
                .fill(Color(hex: template.accentColor))
                .frame(height: 2)

            Spacer(minLength: CartioSpacing.xs)

            if !isThumbnail {
                contactRow
                if !activeSocialLinks.isEmpty {
                    socialIconsRow.padding(.top, CartioSpacing.xs)
                }
            }
        }
        .padding(CartioSpacing.md)
        .frame(maxWidth: .infinity)
    }
}
