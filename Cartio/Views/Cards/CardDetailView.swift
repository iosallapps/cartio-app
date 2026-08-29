//
//  CardDetailView.swift
//  Cartio
//

import SwiftUI

struct CardDetailView: View {
    let card: BusinessCard
    var onEdit: () -> Void
    var onShare: () -> Void
    var onDelete: (() -> Void)?
    var analyticsInteractor: AnalyticsInteractorProtocol?

    @State private var showDeleteConfirmation = false
    @State private var analyticsSummary: AnalyticsSummary?

    var body: some View {
        ZStack {
            CartioMeshBackground()

            ScrollView {
                VStack(spacing: CartioSpacing.lg) {
                    CardPreviewComponent(card: card)
                        .cardShadow()
                        .padding(.top, CartioSpacing.md)

                actionBar

                quickShareRow

                if let summary = analyticsSummary {
                    CardAnalyticsView(summary: summary)
                }

                contactInfoSection

                if !card.bio.isEmpty {
                    bioSection
                }

                if !card.socialLinks.isEmpty {
                    socialLinksSection
                }

                if !card.website.isEmpty {
                    websiteSection
                }

                deleteButton
                    .padding(.top, CartioSpacing.lg)
            }
                .sectionPadding()
                .padding(.bottom, CartioSpacing.xl)
            }
        }
        .navigationTitle(card.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            analyticsSummary = try? await analyticsInteractor?.summary(for: card.id, period: .thirtyDays)
        }
        .alert("Delete Card", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) { onDelete?() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete \"\(card.name)\"? This action cannot be undone.")
        }
    }

    // MARK: - Action Bar

    private var actionBar: some View {
        HStack(spacing: CartioSpacing.md) {
            actionButton(icon: "pencil", label: "Edit", action: onEdit)
            actionButton(icon: "square.and.arrow.up", label: "Share", action: onShare)
            if card.isDefault {
                defaultBadge
            }
        }
    }

    private func actionButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: CartioSpacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: CartioIconSize.lg))
                Text(label)
                    .font(CartioFonts.caption())
            }
            .foregroundStyle(CartioColors.primary)
            .frame(maxWidth: .infinity)
            .padding(CartioSpacing.sm)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: CartioRadius.button))
        }
        .accessibilityLabel("\(label) card")
    }

    private var defaultBadge: some View {
        VStack(spacing: CartioSpacing.xs) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: CartioIconSize.lg))
            Text("Default")
                .font(CartioFonts.caption())
        }
        .foregroundStyle(CartioColors.success)
        .frame(maxWidth: .infinity)
        .padding(CartioSpacing.sm)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: CartioRadius.button))
        .accessibilityLabel("Default card")
    }

    // MARK: - Quick Share Row

    private var quickShareRow: some View {
        HStack(spacing: CartioSpacing.md) {
            quickShareIcon(icon: "qrcode", label: "QR") { onShare() }
            quickShareIcon(icon: "wave.3.right", label: "NFC") { onShare() }
            quickShareIcon(icon: "doc.on.doc", label: "Copy Link") {
                let username = card.name.lowercased().replacingOccurrences(of: " ", with: "")
                let url = "\(AppConstants.URLs.baseURL)/\(username)"
                UIPasteboard.general.string = url
                Haptics.success()
            }
        }
    }

    private func quickShareIcon(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: CartioIconSize.lg))
                Text(label)
                    .font(CartioFonts.caption())
            }
            .foregroundStyle(CartioColors.textSecondary)
            .frame(maxWidth: .infinity)
        }
        .accessibilityLabel("Share via \(label)")
    }

    // MARK: - Contact Info

    private var contactInfoSection: some View {
        Group {
            if !card.email.isEmpty || !card.phone.isEmpty {
                VStack(alignment: .leading, spacing: CartioSpacing.sm) {
                    SectionHeader(title: "Contact")

                    if !card.email.isEmpty {
                        contactRow(icon: "envelope", value: card.email)
                    }
                    if !card.phone.isEmpty {
                        contactRow(icon: "phone", value: card.phone)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func contactRow(icon: String, value: String) -> some View {
        HStack(spacing: CartioSpacing.sm) {
            Image(systemName: icon)
                .foregroundStyle(CartioColors.primary)
                .frame(width: 24)
            Text(value)
                .font(CartioFonts.body())
                .foregroundStyle(CartioColors.textPrimary)
        }
        .padding(CartioSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: CartioRadius.input))
        .accessibilityElement(children: .combine)
    }

    // MARK: - Bio

    private var bioSection: some View {
        VStack(alignment: .leading, spacing: CartioSpacing.sm) {
            SectionHeader(title: "About")
            Text(card.bio)
                .font(CartioFonts.body())
                .foregroundStyle(CartioColors.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Social Links

    private var socialLinksSection: some View {
        VStack(alignment: .leading, spacing: CartioSpacing.sm) {
            SectionHeader(title: "Social")
            ForEach(Array(card.socialLinks.keys.sorted()), id: \.self) { platform in
                if let handle = card.socialLinks[platform], !handle.isEmpty {
                    SocialLinkRow(platform: platform, handle: handle)
                }
            }
        }
    }

    // MARK: - Website

    private var websiteSection: some View {
        VStack(alignment: .leading, spacing: CartioSpacing.sm) {
            SectionHeader(title: "Website")
            HStack(spacing: CartioSpacing.sm) {
                Image(systemName: "globe")
                    .foregroundStyle(CartioColors.primary)
                Text(card.website)
                    .font(CartioFonts.body())
                    .foregroundStyle(CartioColors.primary)
            }
            .padding(CartioSpacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: CartioRadius.input))
        }
    }

    // MARK: - Delete

    private var deleteButton: some View {
        Button(role: .destructive) {
            Haptics.light()
            showDeleteConfirmation = true
        } label: {
            HStack {
                Image(systemName: "trash")
                Text("Delete Card")
            }
            .font(CartioFonts.body())
            .foregroundStyle(CartioColors.error)
            .frame(maxWidth: .infinity)
            .padding(CartioSpacing.md)
            .background(CartioColors.error.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: CartioRadius.button))
        }
        .accessibilityHint("Permanently deletes this card")
    }
}
