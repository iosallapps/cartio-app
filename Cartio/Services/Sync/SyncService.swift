//
//  SyncService.swift
//  Cartio
//

import Foundation
import Combine
import Network

final class SyncService: SyncServiceProtocol {

    var isOnline: Bool { _isOnline }
    var isOnlinePublisher: AnyPublisher<Bool, Never> { _onlineSubject.eraseToAnyPublisher() }

    private var _isOnline = true
    private let _onlineSubject = CurrentValueSubject<Bool, Never>(true)
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "com.cartio.network-monitor")

    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            let online = path.status == .satisfied
            self?._isOnline = online
            self?._onlineSubject.send(online)

            if online {
                Task { [weak self] in
                    try? await self?.processQueue()
                }
            }
        }
        monitor.start(queue: monitorQueue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }

    func processQueue() async throws {
        guard isOnline else { return }
        // TODO: Implement offline queue replay
    }
}
