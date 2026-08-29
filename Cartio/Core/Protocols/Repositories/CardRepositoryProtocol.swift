//
//  CardRepositoryProtocol.swift
//  Cartio
//

import Foundation

@MainActor
protocol CardRepositoryProtocol {
    func fetchAll() async throws -> [BusinessCard]
    func fetch(id: UUID) async throws -> BusinessCard?
    func save(_ card: BusinessCard) async throws
    func delete(_ card: BusinessCard) async throws
    func setDefault(_ card: BusinessCard) async throws
}
