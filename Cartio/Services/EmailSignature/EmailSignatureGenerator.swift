//
//  EmailSignatureGenerator.swift
//  Cartio
//
//  Multi-template HTML email signature generator.
//

import Foundation

enum EmailSignatureStyle: String, CaseIterable, Identifiable {
    case minimal
    case professional
    case corporate
    case creative
    case compact

    var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }

    var description: String {
        switch self {
        case .minimal: return "Clean and simple"
        case .professional: return "Full-featured with dividers"
        case .corporate: return "Bold header with brand color"
        case .creative: return "Two-tone accent design"
        case .compact: return "Single-line contact info"
        }
    }
}

struct EmailSignatureGenerator {

    func generate(for card: BusinessCard, style: EmailSignatureStyle) -> String {
        switch style {
        case .minimal: return minimalSignature(card)
        case .professional: return professionalSignature(card)
        case .corporate: return corporateSignature(card)
        case .creative: return creativeSignature(card)
        case .compact: return compactSignature(card)
        }
    }

    // MARK: - Minimal

    private func minimalSignature(_ card: BusinessCard) -> String {
        let shareURL = shareLink(card)
        return """
        <table cellpadding="0" cellspacing="0" style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;">
          <tr><td style="font-size: 16px; font-weight: 600; color: #1A1A1A;">\(card.name)</td></tr>
          \(card.title.isEmpty ? "" : "<tr><td style=\"font-size: 13px; color: #6B7280;\">\(card.title)\(card.company.isEmpty ? "" : " · \(card.company)")</td></tr>")
          \(contactLine(card, fontSize: "12px"))
          <tr><td style="padding-top: 6px;"><a href="\(shareURL)" style="font-size: 11px; color: #0A7E8C; text-decoration: none;">View my digital card →</a></td></tr>
        </table>
        """
    }

    // MARK: - Professional

    private func professionalSignature(_ card: BusinessCard) -> String {
        let shareURL = shareLink(card)
        return """
        <table cellpadding="0" cellspacing="0" style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; border-collapse: collapse;">
          <tr><td style="font-size: 18px; font-weight: 700; color: #1A1A1A; padding-bottom: 4px;">\(card.name)</td></tr>
          \(card.title.isEmpty ? "" : "<tr><td style=\"font-size: 14px; color: #374151; padding-bottom: 2px;\">\(card.title)</td></tr>")
          \(card.company.isEmpty ? "" : "<tr><td style=\"font-size: 13px; color: #6B7280; padding-bottom: 8px;\">\(card.company)</td></tr>")
          <tr><td style="border-top: 2px solid #0A7E8C; padding-top: 8px;"></td></tr>
          \(contactLine(card, fontSize: "13px"))
          \(socialLine(card))
          <tr><td style="padding-top: 8px;"><a href="\(shareURL)" style="font-size: 12px; color: #0A7E8C; text-decoration: none; font-weight: 500;">📇 Digital Card</a></td></tr>
        </table>
        """
    }

    // MARK: - Corporate

    private func corporateSignature(_ card: BusinessCard) -> String {
        let shareURL = shareLink(card)
        return """
        <table cellpadding="0" cellspacing="0" style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; border-collapse: collapse;">
          <tr>
            <td style="background-color: #0A7E8C; padding: 10px 16px; border-radius: 4px;">
              <span style="font-size: 17px; font-weight: 700; color: #FFFFFF;">\(card.name)</span>
              \(card.title.isEmpty ? "" : "<br><span style=\"font-size: 12px; color: rgba(255,255,255,0.85);\">\(card.title)</span>")
            </td>
          </tr>
          \(card.company.isEmpty ? "" : "<tr><td style=\"font-size: 14px; font-weight: 600; color: #1A1A1A; padding-top: 8px;\">\(card.company)</td></tr>")
          \(contactLine(card, fontSize: "13px"))
          <tr><td style="padding-top: 8px;"><a href="\(shareURL)" style="display: inline-block; background: #0A7E8C; color: white; font-size: 11px; padding: 4px 12px; border-radius: 3px; text-decoration: none;">View Card</a></td></tr>
        </table>
        """
    }

    // MARK: - Creative

    private func creativeSignature(_ card: BusinessCard) -> String {
        let shareURL = shareLink(card)
        return """
        <table cellpadding="0" cellspacing="0" style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; border-collapse: collapse;">
          <tr>
            <td style="border-left: 4px solid #0A7E8C; padding-left: 12px;">
              <span style="font-size: 17px; font-weight: 700; color: #1A1A1A;">\(card.name)</span>
              \(card.title.isEmpty ? "" : "<br><span style=\"font-size: 13px; color: #0A7E8C; font-weight: 500;\">\(card.title)</span>")
              \(card.company.isEmpty ? "" : "<br><span style=\"font-size: 12px; color: #6B7280;\">\(card.company)</span>")
            </td>
          </tr>
          <tr><td style="padding-top: 8px; padding-left: 16px;">\(inlineContact(card))</td></tr>
          \(socialLine(card))
          <tr><td style="padding-top: 6px; padding-left: 16px;"><a href="\(shareURL)" style="font-size: 11px; color: #0A7E8C; text-decoration: none;">cartio.me →</a></td></tr>
        </table>
        """
    }

    // MARK: - Compact

    private func compactSignature(_ card: BusinessCard) -> String {
        let shareURL = shareLink(card)
        var parts = ["\(card.name)"]
        if !card.title.isEmpty { parts.append(card.title) }
        if !card.company.isEmpty { parts.append(card.company) }
        let info = parts.joined(separator: " · ")

        var contact: [String] = []
        if !card.phone.isEmpty { contact.append(card.phone) }
        if !card.email.isEmpty { contact.append(card.email) }
        let contactStr = contact.joined(separator: " | ")

        return """
        <table cellpadding="0" cellspacing="0" style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;">
          <tr><td style="font-size: 13px; color: #1A1A1A; font-weight: 600;">\(info)</td></tr>
          \(contactStr.isEmpty ? "" : "<tr><td style=\"font-size: 12px; color: #6B7280;\">\(contactStr)</td></tr>")
          <tr><td style="font-size: 11px;"><a href="\(shareURL)" style="color: #0A7E8C; text-decoration: none;">Digital Card</a></td></tr>
        </table>
        """
    }

    // MARK: - Helpers

    private func shareLink(_ card: BusinessCard) -> String {
        let username = card.name.lowercased().replacingOccurrences(of: " ", with: "")
        return "\(AppConstants.URLs.baseURL)/\(username)"
    }

    private func contactLine(_ card: BusinessCard, fontSize: String) -> String {
        var parts: [String] = []
        if !card.phone.isEmpty { parts.append(card.phone) }
        if !card.email.isEmpty { parts.append(card.email) }
        guard !parts.isEmpty else { return "" }
        return "<tr><td style=\"padding-top: 4px; font-size: \(fontSize); color: #374151;\">\(parts.joined(separator: " | "))</td></tr>"
    }

    private func inlineContact(_ card: BusinessCard) -> String {
        var parts: [String] = []
        if !card.phone.isEmpty { parts.append(card.phone) }
        if !card.email.isEmpty { parts.append(card.email) }
        return "<span style=\"font-size: 12px; color: #374151;\">\(parts.joined(separator: " · "))</span>"
    }

    private func socialLine(_ card: BusinessCard) -> String {
        let active = card.socialLinks.filter { !$0.value.isEmpty }
        guard !active.isEmpty else { return "" }
        let links = active.map { platform, handle in
            "<a href=\"\(socialURL(platform: platform, handle: handle))\" style=\"font-size: 12px; color: #0A7E8C; text-decoration: none; margin-right: 8px;\">\(platform.capitalized)</a>"
        }.joined()
        return "<tr><td style=\"padding-top: 4px;\">\(links)</td></tr>"
    }

    private func socialURL(platform: String, handle: String) -> String {
        switch platform.lowercased() {
        case "linkedin": return "https://linkedin.com/in/\(handle)"
        case "twitter", "x": return "https://x.com/\(handle)"
        case "instagram": return "https://instagram.com/\(handle)"
        case "github": return "https://github.com/\(handle)"
        default: return handle
        }
    }
}
