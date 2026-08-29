//
//  CardInteractorTests.swift
//  CartioTests
//

import Testing
import Foundation
@testable import Cartio

@MainActor
struct CardInteractorTests {

    // MARK: - Helpers

    private func makeSUT(
        cards: [BusinessCard] = [],
        isPremium: Bool = false
    ) -> (CardInteractor, MockCardRepository, MockSubscriptionInteractor) {
        let repo = MockCardRepository()
        repo.cards = cards
        let sub = MockSubscriptionInteractor()
        sub.isPremium = isPremium
        let interactor = CardInteractor(repository: repo, subscriptionInteractor: sub)
        return (interactor, repo, sub)
    }

    private func makeCard(
        name: String = "Test",
        isDefault: Bool = false
    ) -> BusinessCard {
        BusinessCard(name: name, isDefault: isDefault)
    }

    // MARK: - Fetch

    @Test func fetchCards_returnsAllCards() async throws {
        let cards = [makeCard(name: "A"), makeCard(name: "B")]
        let (sut, _, _) = makeSUT(cards: cards)

        let result = try await sut.fetchCards()
        #expect(result.count == 2)
    }

    @Test func getDefaultCard_returnsDefaultWhenSet() async throws {
        let cards = [makeCard(name: "A"), makeCard(name: "B", isDefault: true)]
        let (sut, _, _) = makeSUT(cards: cards)

        let result = try await sut.getDefaultCard()
        #expect(result?.name == "B")
    }

    @Test func getDefaultCard_returnsFirstWhenNoDefault() async throws {
        let cards = [makeCard(name: "A"), makeCard(name: "B")]
        let (sut, _, _) = makeSUT(cards: cards)

        let result = try await sut.getDefaultCard()
        #expect(result?.name == "A")
    }

    @Test func getDefaultCard_returnsNilWhenEmpty() async throws {
        let (sut, _, _) = makeSUT()

        let result = try await sut.getDefaultCard()
        #expect(result == nil)
    }

    // MARK: - Create

    @Test func createCard_succeedsWhenUnderFreeLimit() async throws {
        let (sut, repo, _) = makeSUT(cards: [makeCard()])

        // Need to call fetchCards first to cache the count
        _ = try await sut.fetchCards()

        let card = try await sut.createCard(
            name: "New", title: "Dev", company: "Co",
            email: "a@b.com", phone: "123", templateID: "classic"
        )
        #expect(card.name == "New")
        #expect(repo.cards.count == 2)
    }

    @Test func createCard_firstCardBecomesDefault() async throws {
        let (sut, _, _) = makeSUT()

        _ = try await sut.fetchCards()
        let card = try await sut.createCard(
            name: "First", title: "", company: "",
            email: "", phone: "", templateID: "classic"
        )
        #expect(card.isDefault == true)
    }

    @Test func createCard_throwsWhenAtFreeLimit() async throws {
        let cards = [makeCard(name: "A"), makeCard(name: "B")]
        let (sut, _, _) = makeSUT(cards: cards)

        _ = try await sut.fetchCards()

        await #expect(throws: CartioError.self) {
            _ = try await sut.createCard(
                name: "Third", title: "", company: "",
                email: "", phone: "", templateID: "classic"
            )
        }
    }

    @Test func createCard_succeedsOverLimitWhenPremium() async throws {
        let cards = [makeCard(name: "A"), makeCard(name: "B")]
        let (sut, _, _) = makeSUT(cards: cards, isPremium: true)

        _ = try await sut.fetchCards()

        let card = try await sut.createCard(
            name: "Third", title: "", company: "",
            email: "", phone: "", templateID: "classic"
        )
        #expect(card.name == "Third")
    }

    // MARK: - Delete

    @Test func deleteCard_removesCard() async throws {
        let card = makeCard(name: "ToDelete")
        let (sut, repo, _) = makeSUT(cards: [card])

        try await sut.deleteCard(card)
        #expect(repo.cards.isEmpty)
    }

    @Test func deleteCard_reassignsDefaultWhenDeletingDefault() async throws {
        let defaultCard = makeCard(name: "Default", isDefault: true)
        let other = makeCard(name: "Other")
        let (sut, repo, _) = makeSUT(cards: [defaultCard, other])

        try await sut.deleteCard(defaultCard)
        #expect(repo.cards.count == 1)
        #expect(repo.cards.first?.isDefault == true)
    }

    // MARK: - Set Default

    @Test func setDefault_updatesDefaultCard() async throws {
        let a = makeCard(name: "A", isDefault: true)
        let b = makeCard(name: "B")
        let (sut, repo, _) = makeSUT(cards: [a, b])

        try await sut.setDefault(b)
        #expect(b.isDefault == true)
        #expect(repo.cards.first(where: { $0.name == "A" })?.isDefault == false)
    }

    // MARK: - Templates

    @Test func getAvailableTemplates_freeUserGetsFreeOnly() {
        let (sut, _, _) = makeSUT()
        let templates = sut.getAvailableTemplates()
        #expect(templates.count == CardTemplate.freeTemplates.count)
        #expect(templates.allSatisfy { !$0.isPremium })
    }

    @Test func getAvailableTemplates_premiumUserGetsAll() {
        let (sut, _, _) = makeSUT(isPremium: true)
        let templates = sut.getAvailableTemplates()
        #expect(templates.count == CardTemplate.allTemplates.count)
    }

    // MARK: - Can Create Card

    @Test func canCreateCard_returnsTrueWhenPremium() async throws {
        let cards = [makeCard(), makeCard()]
        let (sut, _, _) = makeSUT(cards: cards, isPremium: true)
        #expect(try await sut.canCreateCard() == true)
    }

    @Test func canCreateCard_returnsFalseAtLimit() async throws {
        let cards = [makeCard(), makeCard()]
        let (sut, _, _) = makeSUT(cards: cards)
        #expect(try await sut.canCreateCard() == false)
    }
}
