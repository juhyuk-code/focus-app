import SwiftUI
import FamilyControls

struct AppSelectionView: View {
    @EnvironmentObject var appBlockingManager: AppBlockingManager
    @Environment(\.dismiss) private var dismiss

    @State private var isPickerPresented = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "apps.iphone.badge.plus")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)

                    Text("Select Apps to Block")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Choose which apps will be blocked when you activate Focus mode with your NFC chip")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top)

                // Selection Summary
                SelectionSummaryCard(selection: appBlockingManager.selectedApps)

                // Select Apps Button
                Button(action: { isPickerPresented = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Choose Apps & Categories")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)

                // Clear Selection Button
                if appBlockingManager.hasSelectedApps {
                    Button(action: clearSelection) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Clear Selection")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }

                Spacer()

                // Info Card
                InfoCard()
            }
            .navigationTitle("App Selection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        appBlockingManager.saveSelectedApps()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .familyActivityPicker(
                isPresented: $isPickerPresented,
                selection: $appBlockingManager.selectedApps
            )
            .onChange(of: appBlockingManager.selectedApps) { _, _ in
                appBlockingManager.saveSelectedApps()
            }
        }
    }

    private func clearSelection() {
        appBlockingManager.clearSelection()
    }
}

// MARK: - Selection Summary Card
struct SelectionSummaryCard: View {
    let selection: FamilyActivitySelection

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 30) {
                VStack {
                    Text("\(selection.applicationTokens.count)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.blue)
                    Text("Apps")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Divider()
                    .frame(height: 50)

                VStack {
                    Text("\(selection.categoryTokens.count)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.purple)
                    Text("Categories")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Divider()
                    .frame(height: 50)

                VStack {
                    Text("\(selection.webDomainTokens.count)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.orange)
                    Text("Websites")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            if selection.applicationTokens.isEmpty && selection.categoryTokens.isEmpty {
                Text("No apps selected yet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

// MARK: - Info Card
struct InfoCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("How it works", systemImage: "lightbulb.fill")
                .font(.headline)
                .foregroundColor(.orange)

            VStack(alignment: .leading, spacing: 8) {
                InfoRow(number: "1", text: "Select apps and categories to block")
                InfoRow(number: "2", text: "Tap your NFC chip to activate blocking")
                InfoRow(number: "3", text: "Tap the chip again to unblock")
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(16)
        .padding(.horizontal)
        .padding(.bottom)
    }
}

struct InfoRow: View {
    let number: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(Color.orange)
                .clipShape(Circle())

            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    AppSelectionView()
        .environmentObject(AppBlockingManager())
}
