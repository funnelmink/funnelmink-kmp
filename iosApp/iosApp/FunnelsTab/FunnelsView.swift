import SwiftUI

struct FunnelsView: View {
    @StateObject var viewModel = FunnelsViewModel()
    @AppStorage(.storage.funnelsPickerSelection) var selection = "Leads"
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var navigation: Navigation
    
    @ViewBuilder
    var body: some View {
        ZStack {
            //        if FeatureFlags.funnelsTestUI.isEnabled {
            funnelsTestUI
            MenuFAB(
                items: [
                    .init(name: "New Case", iconName: "hazardsign") {
                        navigation.modalSheet(.createCase)
                    },
                    .init(name: "New Opportunity", iconName: "moon.stars") {
                        navigation.modalSheet(.createOpportunity)
                    },
                    .init(name: "New Lead", iconName: "person") {
                        navigation.modalSheet(.createLead)
                    },
                ]
            )
            //        } else {
            //            originalUI
            //        }
        }
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
                ToolbarItem {
                    Picker("Funnels", selection: $selection) {
                        ForEach(viewModel.funnels, id: \.self) { funnel in
                            Text(funnel.name).tag(funnel.name)
                        }
                    }
                }
            }
        }
        .navigationTitle(viewModel.selectedFunnel?.name ?? "Funnels")
        .loggedTask {
            do {
                try await viewModel.setUp(initialSelection: selection)
                // TODO: if !fetchedFunnels.contains(selection) { selection = "Leads" }
                // actually, `selection = funnels.first!.title`
            } catch {
                Toast.error(error)
            }
        }
        .onChange(of: selection) { _ in
            Task {
                do {
                    try await viewModel.selectFunnel(selection)
                } catch {
                    Toast.error(error)
                }
            }
        }
    }
}

#Preview {
    FunnelsView()
        .withPreviewDependencies()
}
