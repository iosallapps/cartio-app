//
//  SettingsView.swift
//  Cartio
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingsView: View {
    @State var viewModel: ProfileViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var showExportSheet = false
    @State private var exportURL: URL?

    var body: some View {
        List {
            Section("Account") {
                HStack {
                    Text("Name")
                    Spacer()
                    Text(viewModel.displayName)
                        .foregroundStyle(CartioColors.textSecondary)
                }
                HStack {
                    Text("Email")
                    Spacer()
                    Text(viewModel.email)
                        .foregroundStyle(CartioColors.textSecondary)
                }
            }

            Section("Preferences") {
                Picker("Appearance", selection: $viewModel.selectedAppearance) {
                    Text("System").tag(0)
                    Text("Light").tag(1)
                    Text("Dark").tag(2)
                }
                .onChange(of: viewModel.selectedAppearance) { _, _ in
                    viewModel.applyAppearance()
                }
            }

            Section("Data") {
                Button {
                    showExportSheet = true
                } label: {
                    Label("Export Contacts", systemImage: "square.and.arrow.up")
                }
                .disabled(!viewModel.isPremium)
                .accessibilityHint(viewModel.isPremium ? "" : "Requires Pro subscription")

                if !viewModel.isPremium {
                    Text("Contact export requires Pro subscription")
                        .font(CartioFonts.caption())
                        .foregroundStyle(CartioColors.textSecondary)
                }
            }

            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                        .foregroundStyle(CartioColors.textSecondary)
                }
            } header: {
                Text("About")
            }

            Section("Danger Zone") {
                Button(role: .destructive) {
                    viewModel.showDeleteConfirmation = true
                } label: {
                    Label("Delete Account", systemImage: "trash")
                }
                .accessibilityHint("Permanently deletes your account and all data")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showExportSheet) {
            let contacts = (try? modelContext.fetch(FetchDescriptor<Contact>())) ?? []
            ContactExportSheet(
                contacts: contacts,
                exportService: DependencyContainer.shared.contactExportService
            )
        }
        .alert("Delete Account?", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                Task { await viewModel.deleteAccount() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone. All your data will be permanently deleted.")
        }
    }
}
