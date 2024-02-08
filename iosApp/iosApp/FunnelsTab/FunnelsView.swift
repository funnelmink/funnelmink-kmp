import SwiftUI

struct FunnelsView: View {
    @StateObject var viewModel = FunnelsViewModel()
    @AppStorage(.storage.funnelsPickerSelection) var selection = "Leads"
    @EnvironmentObject var appState: AppState
    
    @ViewBuilder
    var body: some View {
        //        if FeatureFlags.funnelsTestUI.isEnabled {
        funnelsTestUI
        //        } else {
        //            originalUI
        //        }
    }
    
    var originalUI: some View {
        Text("Funnels")
            .navigationTitle("Funnels")
            .logged()
    }
    
    var funnelsTestUI: some View {
        VStack {
            if viewModel.isInitialized {
                if viewModel.funnels.isEmpty {
                    if appState.isWorkspaceOwner {
                        AsyncButton {
                            do {
                                try await viewModel.createDefaultFunnels()
                            } catch {
                                Toast.error(error)
                            }
                        } label: {
                            Text("Create default funnels")
                        }
                    } else {
                        Text("No funnels found. Ask the workspace owner to create them!")
                    }
                } else {
                    KanbanView(kanban: viewModel)
                }
            } else {
                ProgressView()
            }
        }
        .toolbar {
            if !viewModel.funnels.isEmpty {
                // TODO: this iterates over the actual funnels
                ToolbarItem {
                    Picker("Funnels", selection: $selection) {
                        Text("Leads").tag("Leads")
                    }
                }
            }
        }
        .navigationTitle("Funnels")
        .loggedTask {
            do {
                try await viewModel.fetch()
                // TODO: if !fetchedFunnels.contains(selection) { selection = "Leads" }
                // actually, `selection = funnels.first!.title`
            } catch {
                Toast.error(error)
            }
        }
    }
}

#Preview {
    FunnelsView()
        .withPreviewDependencies()
}
