//
//  ContactFieldsSection.swift
//  Cartio
//

import SwiftUI

struct ContactFieldsSection: View {
    @Binding var email: String
    @Binding var phone: String
    @Binding var website: String

    var body: some View {
        Section {
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
            TextField("Phone", text: $phone)
                .keyboardType(.phonePad)
                .textContentType(.telephoneNumber)
            TextField("Website", text: $website)
                .keyboardType(.URL)
                .textContentType(.URL)
                .autocapitalization(.none)
        } header: {
            Text("Contact")
        }
    }
}
