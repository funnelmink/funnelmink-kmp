import Shared
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
                AsyncButton {
                    do {
                        try await viewModel.createDefaultFunnels()
                    } catch {
                        Toast.error(error)
                    }
                } label: {
                    // TODO: better UI/tutorial
                    Text("Create default funnels")
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
                                Logger.warning(error)
                                Toast.warn("Failed to update card position. Please try again.")
                                try? await viewModel.fetchFunnels(selection)
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
                    if let newSelection = viewModel.funnels.first(where: { $0.type == .case }) {
                        selection = newSelection.name
                    }
                    navigation.modalSheet(.createCase, onDismiss: refreshFunnels)
                },
                .init(name: "New Opportunity", iconName: "moon.stars") {
                    if let newSelection = viewModel.funnels.first(where: { $0.type == .opportunity }) {
                        selection = newSelection.name
                    }
                    navigation.modalSheet(.createOpportunity, onDismiss: refreshFunnels)
                },
                .init(name: "New Lead", iconName: "person") {
                    if let newSelection = viewModel.funnels.first(where: { $0.type == .lead }) {
                        selection = newSelection.name
                    }
                    navigation.modalSheet(.createLead(accountID: nil), onDismiss: refreshFunnels)
                },
            ]
        )
    }
    
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
