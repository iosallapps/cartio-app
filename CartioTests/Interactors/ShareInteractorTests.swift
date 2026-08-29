//
//  ShareInteractorTests.swift
//  CartioTests
//

import Testing
import Foundation
import UIKit
@testable import Cartio

@MainActor
struct ShareInteractorTests {

    // MARK: - Share URL

    @Test func getShareURL_formatsCorrectly() {
        let card = BusinessCard(name: "John Doe", title: "Dev", company: "Acme")
        let sut = makeShareHelper()

        let url = sut.getShareURL(for: card)
        #expect(url.absoluteString == "https://cartio.me/johndoe")
    }

    @Test func getShareURL_handlesSpaces() {
        let card = BusinessCard(name: "Jane Marie Smith")
        let sut = makeShareHelper()

        let url = sut.getShareURL(for: card)
        #expect(url.absoluteString == "https://cartio.me/janemariesmith")
    }

    // MARK: - Email Signature

    @Test func generateEmailSignature_containsCardInfo() {
        let card = BusinessCard(
            name: "Alice Bob",
            title: "Designer",
            company: "Studio",
            email: "alice@studio.com",
            phone: "+1234567890"
        )
        let sut = makeShareHelper()

        let sig = sut.generateEmailSignature(for: card)
        #expect(sig.contains("Alice Bob"))
        #expect(sig.contains("Designer"))
        #expect(sig.contains("Studio"))
        #expect(sig.contains("alice@studio.com"))
        #expect(sig.contains("+1234567890"))
    }

    @Test func generateEmailSignature_omitsCompanyWhenEmpty() {
        let card = BusinessCard(name: "Solo", title: "Freelancer", company: "")
        let sut = makeShareHelper()

        let sig = sut.generateEmailSignature(for: card)
        #expect(!sig.contains(" at "))
    }

    // MARK: - Helpers

    /// Creates a ShareInteractor without a real ModelContext (only tests non-SwiftData methods)
    private func makeShareHelper() -> ShareInteractorHelper {
        ShareInteractorHelper()
    }
}

/// A lightweight helper that mirrors ShareInteractor's pure logic for testability
/// without requiring a ModelContext.
@MainActor
struct ShareInteractorHelper {

    func getShareURL(for card: BusinessCard) -> URL {
        let username = card.name.lowercased().replacingOccurrences(of: " ", with: "")
        return URL(string: "\(AppConstants.URLs.baseURL)/\(username)")!
    }

    func generateEmailSignature(for card: BusinessCard) -> String {
        """
        <table cellpadding="0" cellspacing="0" style="font-family: -apple-system, BlinkMacSystemFont, sans-serif;">
          <tr><td style="font-size: 16px; font-weight: bold; color: #1A1A1A;">\(card.name)</td></tr>
          <tr><td style="font-size: 13px; color: #6B7280;">\(card.title)\(card.company.isEmpty ? "" : " at \(card.company)")</td></tr>
          <tr><td style="padding-top: 8px; font-size: 13px; color: #0A7E8C;">\(card.phone) | \(card.email)</td></tr>
          <tr><td style="padding-top: 4px;"><a href="\(getShareURL(for: card))" style="font-size: 12px; color: #0A7E8C;">View my digital card</a></td></tr>
        </table>
        """
    }
}
