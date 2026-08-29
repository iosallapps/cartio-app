//
//  DesignTokens.swift
//  Cartio
//

import SwiftUI
import UIKit

// MARK: - Colors

enum CartioColors {
    static let primary = Color("CartioPrimary")
    static let secondary = Color("CartioSecondary")
    static let background = Color("Background")
    static let surface = Color("Surface")
    static let textPrimary = Color("TextPrimary")
    static let textSecondary = Color("TextSecondary")
    static let divider = Color("Divider")
    static let success = Color("Success")
    static let warning = Color("Warning")
    static let error = Color("Error")
}

// MARK: - Typography (SF Pro — system default, Dynamic Type enabled via UIFontMetrics)

enum CartioFonts {

    static func largeTitle() -> Font {
        .system(size: UIFontMetrics(forTextStyle: .largeTitle).scaledValue(for: 34), weight: .bold)
    }

    static func title() -> Font {
        .system(size: UIFontMetrics(forTextStyle: .title1).scaledValue(for: 28), weight: .bold)
    }

    static func title2() -> Font {
        .system(size: UIFontMetrics(forTextStyle: .title2).scaledValue(for: 22), weight: .bold)
    }

    static func title3() -> Font {
        .system(size: UIFontMetrics(forTextStyle: .title3).scaledValue(for: 20), weight: .semibold)
    }

    static func headline() -> Font {
        .system(size: UIFontMetrics(forTextStyle: .headline).scaledValue(for: 17), weight: .semibold)
    }

    static func body() -> Font {
        .system(size: UIFontMetrics(forTextStyle: .body).scaledValue(for: 17), weight: .regular)
    }

    static func callout() -> Font {
        .system(size: UIFontMetrics(forTextStyle: .callout).scaledValue(for: 16), weight: .regular)
    }

    static func subheadline() -> Font {
        .system(size: UIFontMetrics(forTextStyle: .subheadline).scaledValue(for: 15), weight: .regular)
    }

    static func footnote() -> Font {
        .system(size: UIFontMetrics(forTextStyle: .footnote).scaledValue(for: 13), weight: .regular)
    }

    static func caption() -> Font {
        .system(size: UIFontMetrics(forTextStyle: .caption1).scaledValue(for: 12), weight: .regular)
    }
}

// MARK: - Spacing

enum CartioSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Corner Radius

enum CartioRadius {
    static let card: CGFloat = 16
    static let button: CGFloat = 22
    static let input: CGFloat = 8
    static let tag: CGFloat = 20
    static let avatar: CGFloat = 50
}

// MARK: - Shadows

enum CartioShadow {
    static let color = Color.black.opacity(0.08)
    static let radius: CGFloat = 8
    static let x: CGFloat = 0
    static let y: CGFloat = 2
}

// MARK: - Gradients

enum CartioGradient {
    /// Primary brand gradient: teal → cyan
    static let primary: [Color] = [CartioColors.primary, Color(red: 0.15, green: 0.65, blue: 0.85)]
    /// Accent gradient: teal → purple
    static let accent: [Color] = [CartioColors.primary, Color(red: 0.4, green: 0.3, blue: 0.85)]
    /// Border gradient: teal → cyan → purple
    static let border: [Color] = [CartioColors.primary, Color(red: 0.15, green: 0.65, blue: 0.85), Color(red: 0.4, green: 0.3, blue: 0.85)]

    static var primaryLinear: LinearGradient {
        LinearGradient(colors: primary, startPoint: .leading, endPoint: .trailing)
    }

    static var accentLinear: LinearGradient {
        LinearGradient(colors: accent, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

// MARK: - Icon Sizes

enum CartioIconSize {
    static let xs: CGFloat = 10
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let hero: CGFloat = 40
    static let display: CGFloat = 48
}

// MARK: - Opacity

enum CartioOpacity {
    static let disabled: Double = 0.5
    static let faded: Double = 0.4
    static let overlay: Double = 0.4
    static let subtle: Double = 0.1
}

// MARK: - Button Heights

enum CartioButtonHeight {
    static let primary: CGFloat = 58
    static let secondary: CGFloat = 50
}
