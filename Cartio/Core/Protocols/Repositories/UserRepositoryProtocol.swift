//
//  UserRepositoryProtocol.swift
//  Cartio
//

import Foundation

@MainActor
protocol UserRepositoryProtocol {
    func getCurrentUser() async throws -> UserProfile?
    func updateProfile(_ profile: UserProfile) async throws
    func deleteAccount() async throws
}
