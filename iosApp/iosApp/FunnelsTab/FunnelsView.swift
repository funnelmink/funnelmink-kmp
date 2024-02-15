import SwiftUI

struct FunnelsView: View {
    @StateObject var viewModel = FunnelsViewModel()
    @AppStorage(.storage.funnelsPickerSelection) var selection = "Leads"
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var navigation: Navigation
    
    @ViewBuilder
    var body: some View {
        ZStack {
            kanbanView
            menuFABView
        }
    }
    
    var kanbanView: some View {
        VStack {
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
                KanbanView(
                    kanban: viewModel,
                    onCardTap: { card in
                        guard
                            let funnel = viewModel.selectedFunnel,
                            let stage = funnel.stages.first(where: { $0.id == card.columnID })
                        else { return }
                        switch viewModel.selectedFunnel?.type {
                        case .lead:
                            guard let lead = funnel.leads.first(where: { $0.id == card.id }) else { fatalError() }
                            navigation.segue(.leadDetails(lead: lead, funnel: funnel, stage: stage))
                        case .case:
                            guard let caseRecord = funnel.cases.first(where: { $0.id == card.id }) else { fatalError() }
                            navigation.segue(.caseDetails(caseRecord: caseRecord, funnel: funnel, stage: stage))
                        case .opportunity:
                            guard let opportunity = funnel.opportunities.first(where: { $0.id == card.id }) else { fatalError() }
                            navigation.segue(.opportunityDetails(opportunity: opportunity, funnel: funnel, stage: stage))
                        case .none: break
                        }
                    }, onColumnDrop: { card, column in
                        Task {
                            do {
                                try await viewModel.assignCard(id: card.id, to: column.id)
                            } catch {
                                // TODO: revert card drop
                                Toast.warn(error)
                            }
                        }
                    }
                )
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
                try await viewModel.fetchFunnels(selection)
            } catch {
                Toast.warn(error)
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
    
    var menuFABView: some View {
        MenuFAB(
            items: [
                .init(name: "New Case", iconName: "hazardsign") {
                    navigation.modalSheet(.createCase, onDismiss: refreshFunnels)
                },
                .init(name: "New Opportunity", iconName: "moon.stars") {
                    navigation.modalSheet(.createOpportunity, onDismiss: refreshFunnels)
                },
                .init(name: "New Lead", iconName: "person") {
                    navigation.modalSheet(.createLead, onDismiss: refreshFunnels)
                },
            ]
        )
    }
    
    @MainActor
    func refreshFunnels() {
        Task {
            do {
                try await viewModel.fetchFunnels(selection)
            } catch {
                Toast.warn(error)
            }
        }
    }
}

#Preview {
    FunnelsView()
        .withPreviewDependencies()
}
