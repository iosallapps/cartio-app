//
//  ContactExportServiceProtocol.swift
//  Cartio
//

import Foundation

enum ExportFormat: String, CaseIterable {
    case vcf = "VCF (vCard)"
    case csv = "CSV"

    var fileExtension: String {
        switch self {
        case .vcf: return "vcf"
        case .csv: return "csv"
        }
    }
}

@MainActor
protocol ContactExportServiceProtocol {
    func export(contacts: [Contact], format: ExportFormat) throws -> URL
}
