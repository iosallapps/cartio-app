//
//  ShareHubView.swift
//  Cartio
//

import SwiftUI
import UIKit

struct ShareHubView: View {
    @ScaledMetric(relativeTo: .body) private var qrSize: CGFloat = 150
    @Environment(AppRouter.self) private var router
    @State private var viewModel: ShareHubViewModel

    init(viewModel: ShareHubViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                CartioMeshBackground()

                ScrollView {
                    VStack(spacing: CartioSpacing.md) {
                    if let card = viewModel.selectedCard {
                        cardHeader(card)

                        if let qrImage = viewModel.qrImage {
                            qrCodeSection(qrImage)
                        }

                        qrColorSection

                        shareMethodsGrid(card)

                        recentSharesSection
                    } else {
                        EmptyStateView(
                            icon: "qrcode",
                            title: "No Card Available",
                            message: "Create a card first to start sharing."
                        )
                    }
                }
                    .sectionPadding()
                }
            }
            .navigationTitle("Share")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Share")
                        .font(CartioFonts.headline())
                        .foregroundStyle(CartioColors.textPrimary)
                }
            }
            .task { await viewModel.loadDefaultCard() }
            .fullScreenCover(isPresented: Binding(
                get: { router.showQRFullscreen },
                set: { router.showQRFullscreen = $0 }
            )) {
                if let qrImage = viewModel.qrImage, let card = viewModel.selectedCard {
                    QRFullscreenView(
                        qrImage: qrImage,
                        name: card.name,
                        title: card.title
                    )
                }
            }
            .sheet(isPresented: $viewModel.showNFCWrite) {
                if let card = viewModel.selectedCard {
                    NFCWriteView(cardURL: viewModel.shareURL?.absoluteString ?? "") { success in
                        viewModel.showNFCWrite = false
                        if success {
                            Task { await viewModel.recordShareMethod(.nfc, for: card) }
                            viewModel.showToast("NFC tag written!")
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.showSignature) {
                if let card = viewModel.selectedCard {
                    EmailSignatureBuilderView(card: card)
                }
            }
            .overlay(alignment: .bottom) {
                if let message = viewModel.toastMessage {
                    ToastView(message: message)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, CartioSpacing.xl)
                }
            }
            .reduceMotionAnimation(.easeInOut(duration: 0.3), value: viewModel.toastMessage)
            .sheet(isPresented: $viewModel.showPaywall) {
                PaywallSheet()
            }
        }
    }

    // MARK: - Card Header

    private func cardHeader(_ card: BusinessCard) -> some View {
        CardPreviewComponent(card: card)
            .cardShadow()
            .frame(height: 140)
    }

    // MARK: - QR Code

    private func qrCodeSection(_ image: UIImage) -> some View {
        VStack(spacing: CartioSpacing.sm) {
            SectionHeader(title: "QR Code")

            Button {
                router.showQRFullscreen = true
            } label: {
                Image(uiImage: image)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: min(qrSize, 220), height: min(qrSize, 220))
                    .padding(CartioSpacing.sm)
                    .background(Color.white) // Intentional: white QR container for readability
                    .clipShape(RoundedRectangle(cornerRadius: CartioRadius.card))
                    .gradientBorder()
                    .cardShadow()
            }
            .accessibilityLabel("QR code for sharing your business card. Tap for fullscreen.")

            Text("Tap to view fullscreen")
                .font(CartioFonts.caption())
                .foregroundStyle(CartioColors.textSecondary)
                .accessibilityHidden(true)
        }
    }

    // MARK: - QR Color Picker

    private var qrColorSection: some View {
        VStack(spacing: CartioSpacing.sm) {
            SectionHeader(title: "QR Color")

            if viewModel.canCustomizeQR {
                ColorPickerComponent(selectedColorHex: Binding(
                    get: { viewModel.qrColorHex },
                    set: { viewModel.updateQRColor($0) }
                ))
            } else {
                ZStack {
                    ColorPickerComponent(selectedColorHex: .constant(viewModel.qrColorHex))
                        .allowsHitTesting(false)
                        .opacity(0.5)

                    Button {
                        viewModel.showPaywall = true
                    } label: {
                        HStack(spacing: CartioSpacing.xs) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: CartioIconSize.sm))
                            Text("Pro Feature")
                                .font(CartioFonts.caption())
                        }
                        .foregroundStyle(CartioColors.background)
                        .padding(.horizontal, CartioSpacing.md)
                        .padding(.vertical, CartioSpacing.sm)
                        .background(CartioColors.primary)
                        .clipShape(Capsule())
                    }
                    .accessibilityLabel("Custom QR colors requires Pro subscription")
                    .accessibilityHint("Double tap to view upgrade options")
                }
            }
        }
    }

    // MARK: - Share Methods Grid

    private func shareMethodsGrid(_ card: BusinessCard) -> some View {
        VStack(spacing: CartioSpacing.sm) {
            SectionHeader(title: "Share Via")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: CartioSpacing.md) {
                shareMethodButton(icon: "doc.on.doc", title: "Copy Link") {
                    viewModel.copyLinkToClipboard()
                    viewModel.showToast("Link copied!")
                }

                shareMethodButton(icon: "wave.3.right", title: "NFC", locked: !viewModel.canAccessNFC) {
                    if viewModel.canAccessNFC {
                        viewModel.showNFCWrite = true
                    } else {
                        viewModel.showPaywall = true
                    }
                }

                shareMethodButton(icon: "square.and.arrow.up", title: "AirDrop") {
                    shareViaAirDrop(card)
                }

                shareMethodButton(icon: "envelope", title: "Email") {
                    shareViaEmail(card)
                }

                shareMethodButton(icon: "text.alignleft", title: "Signature", locked: !viewModel.canAccessSignature) {
                    if viewModel.canAccessSignature {
                        viewModel.showSignature = true
                    } else {
                        viewModel.showPaywall = true
                    }
                }

            }
        }
    }

    private func shareMethodButton(icon: String, title: String, locked: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: CartioSpacing.sm) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: icon)
                        .font(.system(size: CartioIconSize.xl))
                        .frame(height: 28)

                    if locked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: CartioIconSize.xs))
                            .foregroundStyle(.white)
                            .padding(3)
                            .background(CartioColors.secondary)
                            .clipShape(Circle())
                            .offset(x: 8, y: -4)
                    }
                }
                Text(title)
                    .font(CartioFonts.caption())
            }
            .foregroundStyle(locked ? CartioColors.textSecondary : CartioColors.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, CartioSpacing.md)
            .background(CartioColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: CartioRadius.button))
        }
        .accessibilityLabel(locked ? "\(title), requires Pro" : "Share via \(title)")
        .accessibilityHint(locked ? "Requires Pro subscription. Double tap to view upgrade options." : "")
    }

    // MARK: - Recent Shares

    private var recentSharesSection: some View {
        Group {
            if !viewModel.recentShares.isEmpty {
                VStack(alignment: .leading, spacing: CartioSpacing.sm) {
                    SectionHeader(title: "Recent Shares")
                    ForEach(viewModel.recentShares) { share in
                        HStack {
                            Image(systemName: share.method.iconName)
                                .foregroundStyle(CartioColors.primary)
                                .frame(width: 24)
                            Text(share.method.displayName)
                                .font(CartioFonts.body())
                                .foregroundStyle(CartioColors.textPrimary)
                            Spacer()
                            Text(share.timestamp.relativeFormatted)
                                .font(CartioFonts.caption())
                                .foregroundStyle(CartioColors.textSecondary)
                        }
                        .padding(.vertical, CartioSpacing.xs)
                    }
                }
            }
        }
    }

    // MARK: - Share Actions

    private func shareViaAirDrop(_ card: BusinessCard) {
        guard let url = viewModel.shareURL else { return }
        let activityVC = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
        Task { await viewModel.recordShareMethod(.airdrop, for: card) }
    }

    private func shareViaEmail(_ card: BusinessCard) {
        guard let url = viewModel.shareURL else { return }
        let subject = "Check out my digital business card"
        let body = "Hi,\n\nHere's my digital business card: \(url.absoluteString)\n\nBest,\n\(card.name)"
        let mailto = "mailto:?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        if let mailURL = URL(string: mailto) {
            UIApplication.shared.open(mailURL)
        }
        Task { await viewModel.recordShareMethod(.email, for: card) }
    }

}
