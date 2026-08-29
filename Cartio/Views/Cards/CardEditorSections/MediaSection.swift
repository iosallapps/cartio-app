//
//  MediaSection.swift
//  Cartio
//

import SwiftUI
import PhotosUI

struct MediaSection: View {
    @Binding var avatarItem: PhotosPickerItem?
    @Binding var logoItem: PhotosPickerItem?

    var body: some View {
        Section {
            PhotosPicker(selection: $avatarItem, matching: .images) {
                Label("Profile Photo", systemImage: "person.crop.circle")
                    .foregroundStyle(CartioColors.primary)
            }

            PhotosPicker(selection: $logoItem, matching: .images) {
                Label("Company Logo", systemImage: "building.2")
                    .foregroundStyle(CartioColors.primary)
            }
        } header: {
            Text("Media")
        }
    }
}
