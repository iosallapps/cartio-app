//
//  TemplatePickerSection.swift
//  Cartio
//

import SwiftUI

struct TemplatePickerSection: View {
    @Binding var selectedTemplate: CardTemplate
    let templates: [CardTemplate]
    var previewName: String = ""
    var previewTitle: String = ""
    var previewCompany: String = ""

    var body: some View {
        Section {
            TemplatePickerView(
                templates: templates,
                selected: $selectedTemplate,
                previewName: previewName,
                previewTitle: previewTitle,
                previewCompany: previewCompany
            )
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        } header: {
            Text("Template")
        }
    }
}
