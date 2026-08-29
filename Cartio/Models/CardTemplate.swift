//
//  CardTemplate.swift
//  Cartio
//
//  Plain struct — not persisted in SwiftData.
//  Defines available card layout configurations.
//

import SwiftUI

struct CardTemplate: Identifiable, Equatable {
    let id: String
    let name: String
    let category: TemplateCategory
    let backgroundColor: String
    let textColor: String
    let accentColor: String
    let alignment: TemplateAlignment
    let isPremium: Bool
    let layoutStyle: TemplateLayoutStyle

    enum TemplateCategory: String, CaseIterable {
        case minimal
        case corporate
        case creative
        case bold
        case elegant
        case tech

        var displayName: String { rawValue.capitalized }
    }

    enum TemplateAlignment: String {
        case leading
        case center
        case trailing
    }

    enum TemplateLayoutStyle: String, CaseIterable {
        case standard   // Vertical stack with initials circle
        case split      // Two-column: accent panel left, info right
        case banner     // Top accent band with name, info below
        case compact    // Horizontal: initials left, info center, icons right
        case centered   // No initials, large centered name, icon-only contact
        case sidebar    // Vertical accent bar on left, content right
        case topHeavy   // Large name top, accent footer bar with contact
        case divided    // Horizontal accent divider separating name from contact
        case bordered   // Inset accent border frame, centered content
        case minimal    // Name + title only, maximum whitespace
    }
}

// MARK: - Free Templates (8)

extension CardTemplate {

    static let classic = CardTemplate(
        id: "classic", name: "Classic", category: .corporate,
        backgroundColor: "#FFFFFF", textColor: "#1A1A1A", accentColor: "#0A7E8C",
        alignment: .leading, isPremium: false, layoutStyle: .standard
    )

    static let modern = CardTemplate(
        id: "modern", name: "Modern", category: .creative,
        backgroundColor: "#0D1B2A", textColor: "#FFFFFF", accentColor: "#0A7E8C",
        alignment: .leading, isPremium: false, layoutStyle: .banner
    )

    static let minimal = CardTemplate(
        id: "minimal", name: "Minimal", category: .minimal,
        backgroundColor: "#FFFFFF", textColor: "#6B7280", accentColor: "#1A1A1A",
        alignment: .center, isPremium: false, layoutStyle: .minimal
    )

    static let bold = CardTemplate(
        id: "bold", name: "Bold", category: .bold,
        backgroundColor: "#0A7E8C", textColor: "#FFFFFF", accentColor: "#FF6B6B",
        alignment: .center, isPremium: false, layoutStyle: .centered
    )

    static let corporate = CardTemplate(
        id: "corporate", name: "Corporate", category: .corporate,
        backgroundColor: "#F5F5F5", textColor: "#1A1A1A", accentColor: "#0A7E8C",
        alignment: .leading, isPremium: false, layoutStyle: .sidebar
    )

    static let clean = CardTemplate(
        id: "clean", name: "Clean", category: .minimal,
        backgroundColor: "#FAFAFA", textColor: "#374151", accentColor: "#6366F1",
        alignment: .leading, isPremium: false, layoutStyle: .compact
    )

    static let professional = CardTemplate(
        id: "professional", name: "Professional", category: .corporate,
        backgroundColor: "#FFFFFF", textColor: "#1F2937", accentColor: "#2563EB",
        alignment: .leading, isPremium: false, layoutStyle: .divided
    )

    static let startup = CardTemplate(
        id: "startup", name: "Startup", category: .tech,
        backgroundColor: "#F0FDF4", textColor: "#166534", accentColor: "#22C55E",
        alignment: .leading, isPremium: false, layoutStyle: .topHeavy
    )

    // MARK: - Premium Templates (12)

    static let midnight = CardTemplate(
        id: "midnight", name: "Midnight", category: .creative,
        backgroundColor: "#1A1A2E", textColor: "#E0E0E0", accentColor: "#FF6B6B",
        alignment: .leading, isPremium: true, layoutStyle: .banner
    )

    static let ocean = CardTemplate(
        id: "ocean", name: "Ocean", category: .creative,
        backgroundColor: "#0A7E8C", textColor: "#FFFFFF", accentColor: "#0D1B2A",
        alignment: .center, isPremium: true, layoutStyle: .split
    )

    static let slate = CardTemplate(
        id: "slate", name: "Slate", category: .minimal,
        backgroundColor: "#374151", textColor: "#F9FAFB", accentColor: "#10B981",
        alignment: .leading, isPremium: true, layoutStyle: .sidebar
    )

    static let executive = CardTemplate(
        id: "executive", name: "Executive", category: .elegant,
        backgroundColor: "#1C1917", textColor: "#FEF3C7", accentColor: "#D97706",
        alignment: .center, isPremium: true, layoutStyle: .bordered
    )

    static let arctic = CardTemplate(
        id: "arctic", name: "Arctic", category: .minimal,
        backgroundColor: "#F0F9FF", textColor: "#0C4A6E", accentColor: "#38BDF8",
        alignment: .center, isPremium: true, layoutStyle: .minimal
    )

    static let crimson = CardTemplate(
        id: "crimson", name: "Crimson", category: .bold,
        backgroundColor: "#1A1A1A", textColor: "#FFFFFF", accentColor: "#DC2626",
        alignment: .leading, isPremium: true, layoutStyle: .topHeavy
    )

    static let sage = CardTemplate(
        id: "sage", name: "Sage", category: .elegant,
        backgroundColor: "#F5F5F0", textColor: "#374151", accentColor: "#6B8E6B",
        alignment: .leading, isPremium: true, layoutStyle: .divided
    )

    static let neon = CardTemplate(
        id: "neon", name: "Neon", category: .creative,
        backgroundColor: "#0F0F0F", textColor: "#FFFFFF", accentColor: "#A3E635",
        alignment: .center, isPremium: true, layoutStyle: .centered
    )

    static let blueprint = CardTemplate(
        id: "blueprint", name: "Blueprint", category: .tech,
        backgroundColor: "#1E3A5F", textColor: "#E0F2FE", accentColor: "#38BDF8",
        alignment: .leading, isPremium: true, layoutStyle: .split
    )

    static let terracotta = CardTemplate(
        id: "terracotta", name: "Terracotta", category: .elegant,
        backgroundColor: "#FEF2F2", textColor: "#7C2D12", accentColor: "#EA580C",
        alignment: .leading, isPremium: true, layoutStyle: .compact
    )

    static let graphite = CardTemplate(
        id: "graphite", name: "Graphite", category: .corporate,
        backgroundColor: "#27272A", textColor: "#E4E4E7", accentColor: "#A1A1AA",
        alignment: .leading, isPremium: true, layoutStyle: .standard
    )

    static let lavender = CardTemplate(
        id: "lavender", name: "Lavender", category: .creative,
        backgroundColor: "#F5F3FF", textColor: "#4C1D95", accentColor: "#8B5CF6",
        alignment: .center, isPremium: true, layoutStyle: .bordered
    )

    // MARK: - Template Arrays

    static let freeTemplates: [CardTemplate] = [
        classic, modern, minimal, bold, corporate, clean, professional, startup
    ]

    static let premiumTemplates: [CardTemplate] = [
        midnight, ocean, slate, executive, arctic, crimson,
        sage, neon, blueprint, terracotta, graphite, lavender
    ]

    static let allTemplates: [CardTemplate] = freeTemplates + premiumTemplates
}
