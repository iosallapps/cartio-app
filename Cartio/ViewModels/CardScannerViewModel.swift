//
//  CardScannerViewModel.swift
//  Cartio
//

import UIKit

@Observable
final class CardScannerViewModel {

    // Editable fields for scanned data
    var name = ""
    var extractedTitle = ""
    var extractedCompany = ""
    var extractedEmail = ""
    var extractedPhone = ""
    var extractedWebsite = ""
    var notes = ""

    var scannedImage: UIImage?
    var isScanning = false
    var isSaving = false
    var duplicates: [Contact] = []
    var error: CartioError?

    private let scannerService: CardScannerServiceProtocol
    private let contactInteractor: ContactInteractorProtocol

    init(scannerService: CardScannerServiceProtocol, contactInteractor: ContactInteractorProtocol) {
        self.scannerService = scannerService
        self.contactInteractor = contactInteractor
    }

    func scanImage(_ image: UIImage) async {
        isScanning = true
        defer { isScanning = false }

        do {
            let data = try await scannerService.scanImage(image)
            name = data.name ?? ""
            extractedTitle = data.title ?? ""
            extractedCompany = data.company ?? ""
            extractedEmail = data.email ?? ""
            extractedPhone = data.phone ?? ""
            extractedWebsite = data.website ?? ""
            scannedImage = image
        } catch {
            self.error = .ocrFailed
        }
    }

    func checkDuplicates() async {
        guard !name.trimmed.isEmpty else { return }
        let tempContact = Contact(name: name.trimmed, email: extractedEmail.trimmed.isEmpty ? nil : extractedEmail.trimmed)
        duplicates = (try? await contactInteractor.detectDuplicates(for: tempContact)) ?? []
    }

    func saveContact(context: Any? = nil) async {
        guard !name.trimmed.isEmpty else { return }
        isSaving = true
        defer { isSaving = false }

        let contact = Contact(
            name: name.trimmed,
            title: extractedTitle.trimmed.isEmpty ? nil : extractedTitle.trimmed,
            company: extractedCompany.trimmed.isEmpty ? nil : extractedCompany.trimmed,
            email: extractedEmail.trimmed.isEmpty ? nil : extractedEmail.trimmed,
            phone: extractedPhone.trimmed.isEmpty ? nil : extractedPhone.trimmed,
            website: extractedWebsite.trimmed.isEmpty ? nil : extractedWebsite.trimmed,
            source: .scanned
        )
        contact.notes = notes.trimmed.isEmpty ? nil : notes.trimmed

        do {
            try await contactInteractor.saveContact(contact)
        } catch let err as CartioError {
            error = err
        } catch {
            self.error = .unknown(error.localizedDescription)
        }
    }

    func reset() {
        name = ""
        extractedTitle = ""
        extractedCompany = ""
        extractedEmail = ""
        extractedPhone = ""
        extractedWebsite = ""
        notes = ""
        scannedImage = nil
        duplicates = []
        error = nil
    }
}
