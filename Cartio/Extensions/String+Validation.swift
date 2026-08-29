//
//  String+Validation.swift
//  Cartio
//

import Foundation

extension String {
    var isValidEmail: Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return range(of: pattern, options: .regularExpression) != nil
    }

    var isValidPhone: Bool {
        let pattern = #"^[\+]?[\d\s\-\(\)]{7,20}$"#
        return range(of: pattern, options: .regularExpression) != nil
    }

    var isValidURL: Bool {
        let pattern = #"^(https?://)?[\w\-]+(\.[\w\-]+)+[/#?]?.*$"#
        return range(of: pattern, options: .regularExpression) != nil
    }

    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
