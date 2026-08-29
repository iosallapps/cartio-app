//
//  MockAppleContactsService.swift
//  CartioTests
//

import Foundation
@testable import Cartio

@MainActor
final class MockAppleContactsService: AppleContactsServiceProtocol {

    var grantAccess = true
    var contactsToReturn: [Contact] = []
    var savedCards: [BusinessCard] = []

    func requestAccess() async throws -> Bool {
        grantAccess
    }

    func fetchContacts() async throws -> [Contact] {
        contactsToReturn
    }

    func saveContact(from card: BusinessCard) async throws {
        savedCards.append(card)
    }
}
