//
//  CardScannerService.swift
//  Cartio
//
//  VisionKit OCR + regex-based field extraction.
//  ~70% accuracy v1 — manual correction UI is mandatory.
//

import UIKit
import Vision

final class CardScannerService: CardScannerServiceProtocol {

    func scanImage(_ image: UIImage) async throws -> ScannedCardData {
        guard let cgImage = image.cgImage else {
            throw CartioError.ocrFailed
        }

        let recognizedText = try await performOCR(on: cgImage)
        let extracted = extractFields(from: recognizedText)
        return ScannedCardData(
            name: extracted.name,
            title: extracted.title,
            company: extracted.company,
            email: extracted.email,
            phone: extracted.phone,
            website: extracted.website,
            originalImage: image
        )
    }

    // MARK: - OCR

    private func performOCR(on image: CGImage) async throws -> [String] {
        try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let results = request.results as? [VNRecognizedTextObservation] ?? []
                let lines = results.compactMap { $0.topCandidates(1).first?.string }
                continuation.resume(returning: lines)
            }

            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    // MARK: - Field Extraction (regex heuristics — v1)

    private func extractFields(from lines: [String]) -> ExtractedFields {
        var fields = ExtractedFields()

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)

            if fields.email == nil, let email = extractEmail(from: trimmed) {
                fields.email = email
            } else if fields.phone == nil, let phone = extractPhone(from: trimmed) {
                fields.phone = phone
            } else if fields.website == nil, let website = extractWebsite(from: trimmed) {
                fields.website = website
            }
        }

        // Name heuristic: first line that isn't email/phone/website/company indicator
        if let nameLine = lines.first(where: { line in
            !line.contains("@") &&
            !line.contains("www") &&
            !line.contains("http") &&
            extractPhone(from: line) == nil &&
            !line.lowercased().contains("inc") &&
            !line.lowercased().contains("llc") &&
            !line.lowercased().contains("ltd")
        }) {
            fields.name = nameLine
        }

        // Company heuristic: line containing Inc/LLC/Ltd or second non-name line
        fields.company = lines.first(where: { line in
            line.lowercased().contains("inc") ||
            line.lowercased().contains("llc") ||
            line.lowercased().contains("ltd") ||
            line.lowercased().contains("corp")
        })

        return fields
    }

    private func extractEmail(from text: String) -> String? {
        let pattern = #"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}"#
        return text.range(of: pattern, options: .regularExpression).map { String(text[$0]) }
    }

    private func extractPhone(from text: String) -> String? {
        let digits = text.filter { $0.isNumber }
        return digits.count >= 7 ? text : nil
    }

    private func extractWebsite(from text: String) -> String? {
        if text.lowercased().contains("www") || text.lowercased().contains("http") {
            return text
        }
        return nil
    }
}

private struct ExtractedFields {
    var name: String?
    var title: String?
    var company: String?
    var email: String?
    var phone: String?
    var website: String?
}
