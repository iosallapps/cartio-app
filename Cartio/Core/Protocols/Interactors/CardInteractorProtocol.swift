//
//  CardInteractorProtocol.swift
//  Cartio
//

import Foundation

@MainActor
protocol CardInteractorProtocol {
    func fetchCards() async throws -> [BusinessCard]
    func getDefaultCard() async throws -> BusinessCard?
    func createCard(name: String, title: String, company: String, email: String, phone: String, templateID: String) async throws -> BusinessCard
    func saveCard(_ card: BusinessCard) async throws
    func deleteCard(_ card: BusinessCard) async throws
    func setDefault(_ card: BusinessCard) async throws
    func canCreateCard() async throws -> Bool
    func getAvailableTemplates() -> [CardTemplate]
}
