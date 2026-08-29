//
//  NFCWriteView.swift
//  Cartio
//

import SwiftUI
import UIKit

struct NFCWriteView: View {
    let cardURL: String
    var onComplete: (Bool) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isWriting = false
    @State private var writeResult: WriteResult?

    private let nfcService = DependencyContainer.shared.nfcService

    enum WriteResult {
        case success
        case failure(String)
    }

    var body: some View {
        VStack(spacing: CartioSpacing.xl) {
            Spacer()

            nfcIcon

            Text("Write to NFC Tag")
                .font(CartioFonts.title3())
                .foregroundStyle(CartioColors.textPrimary)

            Text("Hold your iPhone near the NFC tag")
                .font(CartioFonts.subheadline())
                .foregroundStyle(CartioColors.textSecondary)

            if !nfcService.isAvailable {
                Label("NFC is not available on this device", systemImage: "exclamationmark.triangle")
                    .foregroundStyle(CartioColors.warning)
                    .font(CartioFonts.footnote())
            }

            if let result = writeResult {
                resultView(result)
            }

            Spacer()

            if writeResult == nil {
                PrimaryButton(title: isWriting ? "Writing..." : "Start Writing") {
                    startWriting()
                }
                .disabled(isWriting || !nfcService.isAvailable)
                .sectionPadding()
            } else {
                HStack(spacing: CartioSpacing.md) {
                    if case .failure = writeResult {
                        PrimaryButton(title: "Try Again") {
                            writeResult = nil
                            startWriting()
                        }
                        .sectionPadding()
                    }

                    SecondaryButton(title: "Done") {
                        onComplete(writeResult != nil && {
                            if case .success = writeResult { return true }
                            return false
                        }())
                    }
                    .sectionPadding()
                }
            }
        }
        .padding(.bottom, CartioSpacing.xl)
    }

    private var nfcIcon: some View {
        Image(systemName: writeResult == nil ? "wave.3.right.circle.fill" : resultIcon)
            .font(.system(size: 80))
            .foregroundStyle(resultColor)
            .symbolEffect(.pulse, isActive: isWriting && !reduceMotion)
            .accessibilityHidden(true)
    }

    private var resultIcon: String {
        switch writeResult {
        case .success: return "checkmark.circle.fill"
        case .failure: return "xmark.circle.fill"
        case .none: return "wave.3.right.circle.fill"
        }
    }

    private var resultColor: Color {
        switch writeResult {
        case .success: return CartioColors.success
        case .failure: return CartioColors.error
        case .none: return CartioColors.primary
        }
    }

    private func startWriting() {
        isWriting = true
        writeResult = nil
        Task {
            do {
                try await nfcService.writeTag(url: cardURL)
                writeResult = .success
                Haptics.success()
                UIAccessibility.post(notification: .announcement, argument: "Written successfully")
            } catch {
                writeResult = .failure(error.localizedDescription)
                Haptics.error()
                UIAccessibility.post(notification: .announcement, argument: error.localizedDescription)
            }
            isWriting = false
        }
    }

    @ViewBuilder
    private func resultView(_ result: WriteResult) -> some View {
        switch result {
        case .success:
            Label("Written successfully!", systemImage: "checkmark.circle.fill")
                .foregroundStyle(CartioColors.success)
                .font(CartioFonts.body())
        case .failure(let message):
            Label(message, systemImage: "xmark.circle.fill")
                .foregroundStyle(CartioColors.error)
                .font(CartioFonts.body())
        }
    }
}
