//
//  AppleContactsServiceProtocol.swift
//  Cartio
//

import Foundation

@MainActor
protocol AppleContactsServiceProtocol {
    func requestAccess() async throws -> Bool
    func fetchContacts() async throws -> [Contact]
    func saveContact(from card: BusinessCard) async throws
}
