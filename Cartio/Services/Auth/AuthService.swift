//
//  AuthService.swift
//  Cartio
//

import Foundation
import Combine

final class AuthService: AuthServiceProtocol {

    var currentUserID: String? { _currentUserID }
    var isAuthenticated: Bool { _currentUserID != nil }
    var authStatePublisher: AnyPublisher<Bool, Never> { _authSubject.eraseToAnyPublisher() }

    private var _currentUserID: String?
    private let _authSubject = CurrentValueSubject<Bool, Never>(false)

    func signInWithApple() async throws -> String {
        // TODO: Implement Firebase Apple Sign-In
        let uid = UUID().uuidString
        _currentUserID = uid
        _authSubject.send(true)
        return uid
    }

    func signInWithGoogle() async throws -> String {
        // TODO: Implement Firebase Google Sign-In
        let uid = UUID().uuidString
        _currentUserID = uid
        _authSubject.send(true)
        return uid
    }

    func signInWithEmail(email: String, password: String) async throws -> String {
        // TODO: Implement Firebase Email Sign-In
        let uid = UUID().uuidString
        _currentUserID = uid
        _authSubject.send(true)
        return uid
    }

    func signUp(email: String, password: String, displayName: String) async throws -> String {
        // TODO: Implement Firebase Sign-Up + create user document
        let uid = UUID().uuidString
        _currentUserID = uid
        _authSubject.send(true)
        return uid
    }

    func signOut() throws {
        _currentUserID = nil
        _authSubject.send(false)
    }

    func deleteAccount() async throws {
        // TODO: Delete Firebase user + Firestore data
        _currentUserID = nil
        _authSubject.send(false)
    }
}
