//
//  UserRepository.swift
//  Cartio
//

import Foundation

final class UserRepository: UserRepositoryProtocol {

    private let authService: AuthServiceProtocol
    private let firestoreService: FirestoreService

    init(authService: AuthServiceProtocol, firestoreService: FirestoreService) {
        self.authService = authService
        self.firestoreService = firestoreService
    }

    func getCurrentUser() async throws -> UserProfile? {
        // TODO: Fetch from Firestore using authService.currentUserID
        return nil
    }

    func updateProfile(_ profile: UserProfile) async throws {
        // TODO: Update in Firestore
    }

    func deleteAccount() async throws {
        try await authService.deleteAccount()
    }
}
