//
//  ContactGroupsView.swift
//  Cartio
//

import SwiftUI
import SwiftData

struct ContactGroupsView: View {
    @Query private var tags: [ContactTag]
    @State private var showNewTag = false
    @State private var newTagName = ""
    @State private var newTagColor = "#0A7E8C"

    private let contactInteractor: ContactInteractorProtocol
    private let colorOptions = ["#0A7E8C", "#FF6B6B", "#10B981", "#F59E0B", "#6366F1", "#EC4899", "#8B5CF6", "#14B8A6"]

    init(contactInteractor: ContactInteractorProtocol) {
        self.contactInteractor = contactInteractor
    }

    var body: some View {
        Group {
            if tags.isEmpty {
                EmptyStateView(
                    icon: "tag",
                    title: "No Tags",
                    message: "Create tags to organize your contacts.",
                    buttonTitle: "Create Tag"
                ) {
                    showNewTag = true
                }
            } else {
                tagList
            }
        }
        .navigationTitle("Groups")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showNewTag = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .alert("New Tag", isPresented: $showNewTag) {
            TextField("Tag name", text: $newTagName)
            Button("Create") {
                createTag()
            }
            Button("Cancel", role: .cancel) {
                newTagName = ""
            }
        } message: {
            Text("Enter a name for the new tag.")
        }
    }

    private var tagList: some View {
        List {
            ForEach(tags) { tag in
                HStack(spacing: CartioSpacing.md) {
                    Circle()
                        .fill(Color(hex: tag.colorHex))
                        .frame(width: 12, height: 12)

                    Text(tag.name)
                        .font(CartioFonts.body())
                        .foregroundStyle(CartioColors.textPrimary)

                    Spacer()

                    Text("\(tag.contacts.count)")
                        .font(CartioFonts.caption())
                        .foregroundStyle(CartioColors.textSecondary)
                        .padding(.horizontal, CartioSpacing.sm)
                        .padding(.vertical, CartioSpacing.xs)
                        .background(CartioColors.surface)
                        .clipShape(Capsule())
                }
                .accessibilityLabel(
                    "\(tag.name), \(tag.contacts.count) \(tag.contacts.count == 1 ? "contact" : "contacts")"
                )
            }
            .onDelete(perform: deleteTags)
        }
        .listStyle(.plain)
    }

    private func createTag() {
        guard !newTagName.trimmed.isEmpty else { return }
        let color = colorOptions.randomElement() ?? "#0A7E8C"
        Task {
            try? await contactInteractor.createTag(name: newTagName.trimmed, colorHex: color)
            Haptics.medium()
        }
        newTagName = ""
    }

    private func deleteTags(at offsets: IndexSet) {
        for index in offsets {
            let tag = tags[index]
            Task {
                try? await contactInteractor.deleteTag(tag)
            }
        }
    }
}
