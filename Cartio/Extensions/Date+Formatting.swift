//
//  Date+Formatting.swift
//  Cartio
//

import Foundation

extension Date {
    var shortFormatted: String {
        formatted(date: .abbreviated, time: .omitted)
    }

    var relativeFormatted: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: .now)
    }

    var dayKey: String {
        formatted(.dateTime.year().month().day())
    }
}
