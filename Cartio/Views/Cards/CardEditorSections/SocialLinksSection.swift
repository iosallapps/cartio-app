//
//  SocialLinksSection.swift
//  Cartio
//

import SwiftUI

struct SocialLinksSection: View {
    @Binding var socialLinks: [String: String]

    private let platforms = ["LinkedIn", "Twitter", "Instagram", "GitHub", "Website"]

    var body: some View {
        Section {
            ForEach(platforms, id: \.self) { platform in
                HStack {
                    Text(platform)
                        .font(CartioFonts.body())
                        .foregroundStyle(CartioColors.textSecondary)
                        .frame(width: 90, alignment: .leading)

                    TextField("Handle or URL", text: binding(for: platform))
                        .autocapitalization(.none)
                }
            }
        } header: {
            Text("Social Links")
        }
    }

    private func binding(for platform: String) -> Binding<String> {
        Binding(
            get: { socialLinks[platform.lowercased()] ?? "" },
            set: { newValue in
                if newValue.isEmpty {
                    socialLinks.removeValue(forKey: platform.lowercased())
                } else {
                    socialLinks[platform.lowercased()] = newValue
                }
            }
        )
    }
}
