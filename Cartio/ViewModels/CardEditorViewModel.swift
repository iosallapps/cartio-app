//
//  CardEditorViewModel.swift
//  Cartio
//

import Foundation
import UIKit

@Observable
final class CardEditorViewModel {

    var name = ""
    var title = ""
    var company = ""
    var email = ""
    var phone = ""
    var website = ""
    var bio = ""
    var selectedTemplate: CardTemplate = .classic
    var socialLinks: [String: String] = [:]
    var colorHex = "#0A7E8C"

    var isSaving = false
    var showError = false
    var errorMessage = ""
    var isCardLimitError = false

    var isEditing: Bool { existingCard != nil }
    var availableTemplates: [CardTemplate] { cardInteractor.getAvailableTemplates() }

    private let cardInteractor: CardInteractorProtocol
    private var existingCard: BusinessCard?

    init(cardInteractor: CardInteractorProtocol, existingCard: BusinessCard? = nil) {
        self.cardInteractor = cardInteractor
        self.existingCard = existingCard

        if let card = existingCard {
            name = card.name
            title = card.title
            company = card.company
            email = card.email
            phone = card.phone
            website = card.website
            bio = card.bio
            selectedTemplate = CardTemplate.allTemplates.first(where: { $0.id == card.templateID }) ?? .classic
            socialLinks = card.socialLinks
            colorHex = card.colorHex
        }
    }

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func save() async {
        guard isValid else { return }
        isSaving = true
        defer { isSaving = false }

        do {
            if let card = existingCard {
                card.name = name.trimmed
                card.title = title.trimmed
                card.company = company.trimmed
                card.email = email.trimmed
                card.phone = phone.trimmed
                card.website = website.trimmed
                card.bio = bio.trimmed
                card.templateID = selectedTemplate.id
                card.socialLinks = socialLinks
                card.colorHex = colorHex
                card.updatedAt = .now
                try await cardInteractor.saveCard(card)
            } else {
                let card = try await cardInteractor.createCard(
                    name: name.trimmed,
                    title: title.trimmed,
                    company: company.trimmed,
                    email: email.trimmed,
                    phone: phone.trimmed,
                    templateID: selectedTemplate.id
                )
                // Set additional fields after creation
                card.website = website.trimmed
                card.bio = bio.trimmed
                card.socialLinks = socialLinks
                card.colorHex = colorHex
                try await cardInteractor.saveCard(card)
            }
            Haptics.medium()
        } catch let err as CartioError {
            errorMessage = err.localizedDescription
            if case .cardLimitReached = err {
                isCardLimitError = true
            } else {
                isCardLimitError = false
            }
            showError = true
        } catch {
            errorMessage = error.localizedDescription
            isCardLimitError = false
            showError = true
        }
    }
}
