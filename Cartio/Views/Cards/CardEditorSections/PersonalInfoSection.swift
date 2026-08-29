//
//  PersonalInfoSection.swift
//  Cartio
//

import SwiftUI

struct PersonalInfoSection: View {
    @Binding var name: String
    @Binding var title: String
    @Binding var company: String
    @Binding var bio: String

    var body: some View {
        Section {
            TextField("Full Name *", text: $name)
            TextField("Job Title", text: $title)
            TextField("Company", text: $company)
            TextField("Bio", text: $bio, axis: .vertical)
                .lineLimit(3...6)
        } header: {
            Text("Personal Info")
        }
    }
}
