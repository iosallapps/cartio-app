//
//  EmailSignatureBuilderView.swift
//  Cartio
//

import SwiftUI
import WebKit

struct EmailSignatureBuilderView: View {
    let card: BusinessCard
    @Environment(\.dismiss) private var dismiss

    @State private var selectedStyle: EmailSignatureStyle = .professional
    @State private var showCopiedToast = false

    private let generator = EmailSignatureGenerator()

    private var signatureHTML: String {
        generator.generate(for: card, style: selectedStyle)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Style picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: CartioSpacing.sm) {
                        ForEach(EmailSignatureStyle.allCases) { style in
                            Button {
                                selectedStyle = style
                                Haptics.selection()
                            } label: {
                                VStack(spacing: CartioSpacing.xs) {
                                    Text(style.displayName)
                                        .font(CartioFonts.caption())
                                        .fontWeight(selectedStyle == style ? .semibold : .regular)
                                }
                                .padding(.horizontal, CartioSpacing.md)
                                .padding(.vertical, CartioSpacing.sm)
                                .background(selectedStyle == style ? CartioColors.primary : CartioColors.surface)
                                .foregroundStyle(
                                    selectedStyle == style ? CartioColors.background : CartioColors.textPrimary
                                )
                                .clipShape(Capsule())
                                .accessibilityAddTraits(selectedStyle == style ? .isSelected : [])
                            }
                        }
                    }
                    .padding(.horizontal, CartioSpacing.lg)
                    .padding(.vertical, CartioSpacing.sm)
                }

                // Live preview
                VStack(alignment: .leading, spacing: CartioSpacing.sm) {
                    Text("Preview")
                        .font(CartioFonts.headline())
                        .foregroundStyle(CartioColors.textPrimary)
                        .padding(.horizontal, CartioSpacing.lg)

                    SignatureWebView(html: signatureHTML)
                        .frame(height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: CartioRadius.card))
                        .padding(.horizontal, CartioSpacing.lg)
                        .accessibilityLabel("Email signature preview")
                }

                Spacer()

                // Actions
                VStack(spacing: CartioSpacing.sm) {
                    PrimaryButton(title: "Copy HTML") {
                        UIPasteboard.general.string = signatureHTML
                        Haptics.success()
                        showCopiedToast = true
                        Task {
                            try? await Task.sleep(for: .seconds(2))
                            showCopiedToast = false
                        }
                    }
                    .accessibilityHint("Copies HTML signature code to clipboard")

                    Button("Copy as Plain Text") {
                        let plain = plainTextSignature(card)
                        UIPasteboard.general.string = plain
                        Haptics.success()
                        showCopiedToast = true
                        Task {
                            try? await Task.sleep(for: .seconds(2))
                            showCopiedToast = false
                        }
                    }
                    .font(CartioFonts.subheadline())
                    .foregroundStyle(CartioColors.primary)
                    .accessibilityHint("Copies plain text signature to clipboard")
                }
                .padding(.horizontal, CartioSpacing.lg)
                .padding(.bottom, CartioSpacing.md)
            }
            .navigationTitle("Email Signature")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .overlay(alignment: .bottom) {
                if showCopiedToast {
                    ToastView(message: "Copied to clipboard!")
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, CartioSpacing.xxl + CartioSpacing.xxl)
                }
            }
            .reduceMotionAnimation(.easeInOut(duration: 0.3), value: showCopiedToast)
        }
    }

    private func plainTextSignature(_ card: BusinessCard) -> String {
        var lines = [card.name]
        if !card.title.isEmpty { lines.append(card.title) }
        if !card.company.isEmpty { lines.append(card.company) }
        lines.append("")
        if !card.phone.isEmpty { lines.append(card.phone) }
        if !card.email.isEmpty { lines.append(card.email) }
        let username = card.name.lowercased().replacingOccurrences(of: " ", with: "")
        lines.append("\(AppConstants.URLs.baseURL)/\(username)")
        return lines.joined(separator: "\n")
    }
}

// MARK: - WKWebView Wrapper

private struct SignatureWebView: UIViewRepresentable {
    let html: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .white
        webView.scrollView.isScrollEnabled = false
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let fullHTML = """
        <html>
        <head><meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>body { margin: 16px; background: white; }</style></head>
        <body>\(html)</body>
        </html>
        """
        webView.loadHTMLString(fullHTML, baseURL: nil)
    }
}
