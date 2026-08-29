//
//  SocialLinkRow.swift
//  Cartio
//

import SwiftUI

struct SocialLinkRow: View {
    let platform: String
    let handle: String

    var body: some View {
        HStack(spacing: CartioSpacing.md) {
            Image(systemName: iconForPlatform(platform))
                .font(.system(size: 20))
                .foregroundStyle(CartioColors.primary)
                .frame(width: 28)

            VStack(alignment: .leading) {
                Text(platform.capitalized)
                    .font(CartioFonts.footnote())
                    .foregroundStyle(CartioColors.textSecondary)
                Text(handle)
                    .font(CartioFonts.body())
                    .foregroundStyle(CartioColors.textPrimary)
            }

            Spacer()
        }
    }

    private func iconForPlatform(_ platform: String) -> String {
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
