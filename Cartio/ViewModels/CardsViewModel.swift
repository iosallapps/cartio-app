//
//  CardsViewModel.swift
//  Cartio
//

import Foundation

@Observable
final class CardsViewModel {

    var cards: [BusinessCard] = []
    var selectedCard: BusinessCard?
    var showEditor = false
    var editingCard: BusinessCard?
    var isLoading = false
    var error: CartioError?

    private let cardInteractor: CardInteractorProtocol

    init(cardInteractor: CardInteractorProtocol) {
        self.cardInteractor = cardInteractor
    }

    func loadCards() async {
        isLoading = true
        defer { isLoading = false }

        do {
            cards = try await cardInteractor.fetchCards()
        } catch let err as CartioError {
            error = err
        } catch {
            self.error = .unknown(error.localizedDescription)
        }
    }

    func deleteCard(_ card: BusinessCard) async {
        do {
            try await cardInteractor.deleteCard(card)
            await loadCards()
        } catch let err as CartioError {
            error = err
        } catch {
            self.error = .unknown(error.localizedDescription)
        }
    }

    func setDefault(_ card: BusinessCard) async {
        do {
            try await cardInteractor.setDefault(card)
            await loadCards()
        } catch let err as CartioError {
            error = err
        } catch {
            self.error = .unknown(error.localizedDescription)
        }
    }

    var defaultCard: BusinessCard? {
        cards.first(where: { $0.isDefault }) ?? cards.first
    }
}
