//
//  NFCService.swift
//  Cartio
//
//  CoreNFC read/write. Write only works in foreground with active session.
//  Supported tags: NTAG213, NTAG215, NTAG216.
//

import Foundation
@preconcurrency import CoreNFC

final class NFCService: NSObject, NFCServiceProtocol {

    var isAvailable: Bool {
        NFCNDEFReaderSession.readingAvailable
    }

    private nonisolated(unsafe) var readContinuation: CheckedContinuation<String, Error>?
    private nonisolated(unsafe) var writeContinuation: CheckedContinuation<Void, Error>?
    private nonisolated(unsafe) var urlToWrite: String?

    func readTag() async throws -> String {
        guard isAvailable else { throw CartioError.nfcNotAvailable }

        return try await withCheckedThrowingContinuation { continuation in
            // Cancel any orphaned continuation before replacing
            readContinuation?.resume(throwing: CartioError.nfcNotAvailable)
            readContinuation = continuation
            let session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
            session.alertMessage = "Hold your iPhone near the NFC tag."
            session.begin()
        }
    }

    func writeTag(url: String) async throws {
        guard isAvailable else { throw CartioError.nfcNotAvailable }

        urlToWrite = url

        return try await withCheckedThrowingContinuation { continuation in
            // Cancel any orphaned continuation before replacing
            writeContinuation?.resume(throwing: CartioError.nfcNotAvailable)
            writeContinuation = continuation
            let session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
            session.alertMessage = "Hold your iPhone near an NFC tag to write."
            session.begin()
        }
    }
}

// MARK: - NFCNDEFReaderSessionDelegate

extension NFCService: NFCNDEFReaderSessionDelegate {

    nonisolated func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        guard let record = messages.first?.records.first,
              let url = String(data: record.payload, encoding: .utf8) else {
            readContinuation?.resume(throwing: CartioError.nfcWriteFailed)
            readContinuation = nil
            return
        }
        readContinuation?.resume(returning: url)
        readContinuation = nil
    }

    nonisolated func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [any NFCNDEFTag]) {
        guard let tag = tags.first, let urlToWrite else { return }

        nonisolated(unsafe) let safeSession = session
        nonisolated(unsafe) let safeTag = tag
        safeSession.connect(to: safeTag) { [weak self] (error: (any Error)?) in
            if let error {
                safeSession.invalidate(errorMessage: "Connection failed: \(error.localizedDescription)")
                self?.writeContinuation?.resume(throwing: CartioError.nfcWriteFailed)
                self?.writeContinuation = nil
                return
            }

            guard let url = URL(string: urlToWrite),
                  let uriRecord = NFCNDEFPayload.wellKnownTypeURIPayload(url: url) else {
                safeSession.invalidate(errorMessage: "Invalid URL for NFC tag.")
                self?.writeContinuation?.resume(throwing: CartioError.nfcWriteFailed)
                self?.writeContinuation = nil
                return
            }
            let message = NFCNDEFMessage(records: [uriRecord])

            safeTag.writeNDEF(message) { [weak self] (error: (any Error)?) in
                if let error {
                    safeSession.invalidate(errorMessage: "Write failed: \(error.localizedDescription)")
                    self?.writeContinuation?.resume(throwing: CartioError.nfcWriteFailed)
                } else {
                    safeSession.alertMessage = "Tag written successfully!"
                    safeSession.invalidate()
                    self?.writeContinuation?.resume()
                }
                self?.writeContinuation = nil
            }
        }
    }

    nonisolated func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {}

    nonisolated func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: any Error) {
        let nfcError = error as? NFCReaderError
        if nfcError?.code != .readerSessionInvalidationErrorFirstNDEFTagRead &&
            nfcError?.code != .readerSessionInvalidationErrorUserCanceled {
            readContinuation?.resume(throwing: CartioError.nfcWriteFailed)
            writeContinuation?.resume(throwing: CartioError.nfcWriteFailed)
        }
        readContinuation = nil
        writeContinuation = nil
    }
}
