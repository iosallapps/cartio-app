//
//  AuthServiceProtocol.swift
//  Cartio
//

import Foundation
import Combine

@MainActor
protocol AuthServiceProtocol {
    var currentUserID: String? { get }
    var isAuthenticated: Bool { get }
    var authStatePublisher: AnyPublisher<Bool, Never> { get }

    func signInWithApple() async throws -> String
    func signInWithGoogle() async throws -> String
    func signInWithEmail(email: String, password: String) async throws -> String
    func signUp(email: String, password: String, displayName: String) async throws -> String
    func signOut() throws
    func deleteAccount() async throws
}
