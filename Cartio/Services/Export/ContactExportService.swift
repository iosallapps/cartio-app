//
//  ContactExportService.swift
//  Cartio
//

import Foundation

final class ContactExportService: ContactExportServiceProtocol {

    func export(contacts: [Contact], format: ExportFormat) throws -> URL {
        switch format {
        case .vcf: return try exportVCF(contacts)
        case .csv: return try exportCSV(contacts)
        }
    }

    // MARK: - VCF

    private func exportVCF(_ contacts: [Contact]) throws -> URL {
        var vcards = ""
        for contact in contacts {
            vcards += buildVCard(contact)
        }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("cartio_contacts.vcf")
        try vcards.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    private func buildVCard(_ contact: Contact) -> String {
        var lines = ["BEGIN:VCARD", "VERSION:3.0"]
        lines.append("FN:\(contact.name)")

        let parts = contact.name.split(separator: " ", maxSplits: 1)
        let first = parts.first.map(String.init) ?? ""
        let last = parts.count > 1 ? String(parts[1]) : ""
        lines.append("N:\(last);\(first);;;")

        if let org = contact.company { lines.append("ORG:\(org)") }
        if let title = contact.title { lines.append("TITLE:\(title)") }
        if let email = contact.email { lines.append("EMAIL;TYPE=INTERNET:\(email)") }
        if let phone = contact.phone { lines.append("TEL;TYPE=CELL:\(phone)") }
        if let website = contact.website { lines.append("URL:\(website)") }
        if let notes = contact.notes { lines.append("NOTE:\(notes.replacingOccurrences(of: "\n", with: "\\n"))") }

        lines.append("END:VCARD")
        return lines.joined(separator: "\r\n") + "\r\n"
    }

    // MARK: - CSV

    private func exportCSV(_ contacts: [Contact]) throws -> URL {
        var csv = "Name,Title,Company,Email,Phone,Website,Notes,Source,Created\n"
        for contact in contacts {
            let row = [
                csvEscape(contact.name),
                csvEscape(contact.title ?? ""),
                csvEscape(contact.company ?? ""),
                csvEscape(contact.email ?? ""),
                csvEscape(contact.phone ?? ""),
                csvEscape(contact.website ?? ""),
                csvEscape(contact.notes ?? ""),
                csvEscape(contact.source.rawValue),
                csvEscape(contact.createdAt.ISO8601Format())
            ]
            csv += row.joined(separator: ",") + "\n"
        }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("cartio_contacts.csv")
        try csv.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    private func csvEscape(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") || value.contains("\n") {
            return "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return value
    }
}
