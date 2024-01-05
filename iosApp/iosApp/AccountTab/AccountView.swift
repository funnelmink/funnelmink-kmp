import SwiftUI

struct AccountView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var navigation: Navigation
    @StateObject var viewModel = AccountViewModel()
    var body: some View {
        List {
            Section {
                Button {
                    // TODO: can edit user's name, email, avatar, etc
                } label: {
                    HStack {
                    VStack(alignment: .leading) {
                        Text("\(appState.user?.displayName ?? "Your account")")
                            .font(.headline)
                            .fontWeight(.bold)
                            Text("\(appState.user?.email ?? "Workspace settings")")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                        }
                        Spacer()
                        chevron
                    }
                }
                Button {
                    navigation.performSegue(.workspaceSettings)
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(appState.workspace?.name ?? "")
                        }
                        Spacer()
                        chevron
                    }
                }
            }
            
            Section(header: Text("Settings (none of these work)")) {
                settingRow(systemIcon: "bell", text: "Notifications")
                settingRow(systemIcon: "lock", text: "Privacy")
                settingRow(systemIcon: "envelope", text: "Email")
                settingRow(systemIcon: "questionmark.circle", text: "Help")
                settingRow(systemIcon: "exclamationmark.circle", text: "Report a problem")
            }
            
            Section {
                WarningAlertButton(
                    warningMessage: "Are you sure you want to sign out?",
                    action: {
                        appState.signOut()
                    },
                    label: {
                        Text("Sign out").foregroundStyle(.red)
                    }
                )
            }
        }
        .tint(.primary)
        .navigationTitle("Account")
    }
    
    private var chevron: some View {
        Image(systemName: "chevron.right").foregroundColor(.gray)
    }
    
    private func settingRow(systemIcon: String, text: String) -> some View {
        HStack {
            Image(systemName: systemIcon)
            Text(text)
            Spacer()
            chevron
        }
    }
}

#Preview {
    AccountView()
        .environmentObject(AppState())
}
