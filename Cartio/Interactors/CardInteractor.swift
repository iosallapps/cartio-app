//
//  CardInteractor.swift
//  Cartio
//

import Foundation
import WidgetKit

final class CardInteractor: CardInteractorProtocol {

    private let repository: CardRepositoryProtocol
    private let subscriptionInteractor: SubscriptionInteractorProtocol
    private var isCreating = false

    init(repository: CardRepositoryProtocol, subscriptionInteractor: SubscriptionInteractorProtocol) {
        self.repository = repository
        self.subscriptionInteractor = subscriptionInteractor
    }

    func fetchCards() async throws -> [BusinessCard] {
        try await repository.fetchAll()
    }

    func getDefaultCard() async throws -> BusinessCard? {
        let cards = try await repository.fetchAll()
        return cards.first(where: { $0.isDefault }) ?? cards.first
    }

    func createCard(
        name: String,
        title: String,
        company: String,
        email: String,
        phone: String,
        templateID: String
    ) async throws -> BusinessCard {
        guard !isCreating else { throw CartioError.cardLimitReached }
        isCreating = true
        defer { isCreating = false }

        let cards = try await repository.fetchAll()

        guard subscriptionInteractor.isPremium || cards.count < AppConstants.FreeTier.maxCards else {
            throw CartioError.cardLimitReached
        }
        let isFirst = cards.isEmpty

        let card = BusinessCard(
            name: name,
            title: title,
            company: company,
            email: email,
            phone: phone,
            templateID: templateID,
            isDefault: isFirst
        )

        try await repository.save(card)
        return card
    }

    func saveCard(_ card: BusinessCard) async throws {
        try await repository.save(card)
        if card.isDefault {
            WidgetDataManager.saveDefaultCard(from: card)
        }
    }

    func deleteCard(_ card: BusinessCard) async throws {
        let wasDefault = card.isDefault
        try await repository.delete(card)

        // If deleted card was default, make another one default
        if wasDefault {
            let remaining = try await repository.fetchAll()
            if let first = remaining.first {
                try await repository.setDefault(first)
            }
        }
    }

    func setDefault(_ card: BusinessCard) async throws {
        try await repository.setDefault(card)
        WidgetDataManager.saveDefaultCard(from: card)
    }

    func canCreateCard() async throws -> Bool {
        if subscriptionInteractor.isPremium { return true }
        let cards = try await repository.fetchAll()
        return cards.count < AppConstants.FreeTier.maxCards
    }

    func getAvailableTemplates() -> [CardTemplate] {
        if subscriptionInteractor.isPremium {
            return CardTemplate.allTemplates
        }
        return CardTemplate.freeTemplates
    }
}
