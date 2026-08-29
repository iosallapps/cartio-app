//
//  CardPreviewComponent.swift
//  Cartio
//
//  MOST REUSED COMPONENT: Renders a business card visually.
//  Used in: editor, list, detail, share hub, onboarding, widget.
//  Layout variations defined in CardLayouts/ directory.
//

import SwiftUI

struct CardPreviewComponent: View {
    let name: String
    let title: String
    let company: String
    let email: String
    let phone: String
    let website: String
    let socialLinks: [String: String]
    let template: CardTemplate
    var isThumbnail: Bool = false

    var body: some View {
        layoutContent
            .frame(maxWidth: .infinity)
            .background(Color(hex: template.backgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: CartioRadius.card))
            .gradientBorder(animated: !isThumbnail)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(accessibilityDescription)
    }

    // MARK: - Layout Router

    @ViewBuilder
    private var layoutContent: some View {
        switch template.layoutStyle {
        case .standard: standardLayout
        case .split:    splitLayout
        case .banner:   bannerLayout
        case .compact:  compactLayout
        case .centered: centeredLayout
        case .sidebar:  sidebarLayout
        case .topHeavy: topHeavyLayout
        case .divided:  dividedLayout
        case .bordered: borderedLayout
        case .minimal:  minimalLayout
        }
    }

    // MARK: - Shared Subviews

    var initialsCircle: some View {
        let initials = name.components(separatedBy: " ")
            .prefix(2)
            .compactMap { $0.first.map(String.init) }
            .joined()

        return Text(initials.isEmpty ? "?" : initials)
            .font(CartioFonts.subheadline())
            .foregroundStyle(.white)
            .frame(width: 36, height: 36) // Intentional: fixed size for card layout consistency
            .background(Color(hex: template.accentColor))
            .clipShape(Circle())
    }

    var contactRow: some View {
        VStack(alignment: template.alignment == .center ? .center : .leading, spacing: CartioSpacing.xs) {
            if !email.isEmpty {
                Label(email, systemImage: "envelope")
                    .font(CartioFonts.caption())
                    .foregroundStyle(Color(hex: template.textColor).opacity(0.6))
                    .lineLimit(1)
            }
            if !phone.isEmpty {
                Label(phone, systemImage: "phone")
                    .font(CartioFonts.caption())
                    .foregroundStyle(Color(hex: template.textColor).opacity(0.6))
                    .lineLimit(1)
            }
            if !website.isEmpty {
                Label(website, systemImage: "globe")
                    .font(CartioFonts.caption())
                    .foregroundStyle(Color(hex: template.textColor).opacity(0.6))
                    .lineLimit(1)
            }
        }
    }

    var activeSocialLinks: [(String, String)] {
        socialLinks.filter { !$0.value.isEmpty }.sorted { $0.key < $1.key }
    }

    var socialIconsRow: some View {
        HStack(spacing: CartioSpacing.sm) {
            ForEach(activeSocialLinks.prefix(5), id: \.0) { platform, _ in
                Image(systemName: socialIcon(for: platform))
                    .font(.system(size: CartioIconSize.sm))
                    .foregroundStyle(Color(hex: template.accentColor))
            }
        }
        .padding(.top, CartioSpacing.xs)
    }

    // MARK: - Helpers

    private var accessibilityDescription: String {
        var parts = [name.isEmpty ? "Empty card" : name]
        if !title.isEmpty { parts.append(title) }
        if !company.isEmpty { parts.append(company) }
        if !email.isEmpty { parts.append("Email: \(email)") }
        if !phone.isEmpty { parts.append("Phone: \(phone)") }
        return parts.joined(separator: ", ")
    }

    func socialIcon(for platform: String) -> String {
        switch platform.lowercased() {
        case "linkedin": return "link"
        case "twitter", "x": return "at"
        case "instagram": return "camera"
        case "github": return "chevron.left.forwardslash.chevron.right"
        case "website": return "globe"
        default: return "link"
        }
    }
}

// MARK: - Convenience init from BusinessCard model

extension CardPreviewComponent {
    init(card: BusinessCard) {
        self.name = card.name
        self.title = card.title
        self.company = card.company
        self.email = card.email
        self.phone = card.phone
        self.website = card.website
        self.socialLinks = card.socialLinks
        self.template = CardTemplate.allTemplates.first(where: { $0.id == card.templateID }) ?? .classic
        self.isThumbnail = false
    }
}

// MARK: - Editor convenience init

extension CardPreviewComponent {
    init(
        name: String,
        title: String,
        company: String,
        email: String,
        phone: String,
        template: CardTemplate
    ) {
        self.name = name
        self.title = title
        self.company = company
        self.email = email
        self.phone = phone
        self.website = ""
        self.socialLinks = [:]
        self.template = template
        self.isThumbnail = false
    }
}
