//
//  ManualContactSheet.swift
//  Cartio
//

import SwiftUI

struct ManualContactSheet: View {
    let contactInteractor: ContactInteractorProtocol
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var title = ""
    @State private var company = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var website = ""
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Personal") {
                    TextField("Name *", text: $name)
                    TextField("Title", text: $title)
                    TextField("Company", text: $company)
                }

                Section("Contact Info") {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                    TextField("Website", text: $website)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                }

                Section("Notes") {
                    TextField("Notes...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("New Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            let contact = Contact(
                                name: name.trimmed,
                                title: title.trimmed.isEmpty ? nil : title.trimmed,
                                company: company.trimmed.isEmpty ? nil : company.trimmed,
                                email: email.trimmed.isEmpty ? nil : email.trimmed,
                                phone: phone.trimmed.isEmpty ? nil : phone.trimmed,
                                website: website.trimmed.isEmpty ? nil : website.trimmed,
                                notes: notes.trimmed.isEmpty ? nil : notes.trimmed,
                                source: .manual
                            )
                            try? await contactInteractor.saveContact(contact)
                            Haptics.medium()
                            dismiss()
                        }
                    }
                    .disabled(name.trimmed.isEmpty)
                    .accessibilityHint(name.trimmed.isEmpty ? "Enter a name to enable saving" : "")
                }
            }
        }
    }
}
