//
//  FunnelsViewModel.swift
//  iosApp
//
//  Created by Jared Warren on 1/26/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Foundation
import Shared

class FunnelsViewModel: ViewModel, KanbanViewModel {
    @Published var columns: [KanbanColumn] = []
    @Published var state = State()
    
    struct State: Hashable {
        var funnels: [Funnel] = []
        var selectedFunnel: Funnel?
    }
    
    @MainActor
    func selectFunnel(_ funnel: Funnel) async throws {
        columns.removeAll()
        self.state.selectedFunnel = funnel
        for stage in funnel.stages {
            var cards = [KanbanCard]()
            
            switch funnel.type {
            case .lead:
                for lead in funnel.leads where lead.stageID == stage.id {
                    let card = KanbanCard(
                        id: lead.id,
                        title: lead.name,
                        subtitleLabel: .init(iconName: "note.text", text: lead.notes ?? "--"),
                        footerLabel: nil,
                        secondFooterLabel: nil,
                        footerTrailingText: "",
                        columnID: lead.stageID ?? stage.id
                    )
                    cards.append(card)
                }
            case .case:
                for caseRecord in funnel.cases where caseRecord.stageID == stage.id {
                    let card = KanbanCard(
                        id: caseRecord.id,
                        title: caseRecord.name,
                        subtitleLabel: .init(iconName: "note.text", text: caseRecord.notes ?? "--"),
                        footerLabel: .init(
                            iconName: "banknote",
                            text: caseRecord.value.currencyFormat
                        ),
                        secondFooterLabel: nil,
                        footerTrailingText: "",
                        columnID: caseRecord.stageID ?? stage.id
                    )
                    cards.append(card)
                }
            case .opportunity:
                for opportunity in funnel.opportunities where opportunity.stageID == stage.id {
                    let card = KanbanCard(
                        id: opportunity.id,
                        title: opportunity.name,
                        subtitleLabel: .init(iconName: "note.text", text: opportunity.notes ?? "--"),
                        footerLabel: .init(
                            iconName: "banknote",
                            text: opportunity.value.currencyFormat
                        ),
                        secondFooterLabel: nil,
                        footerTrailingText: "",
                        columnID: opportunity.stageID ?? stage.id
                    )
                    cards.append(card)
                }
            }
            let column = KanbanColumn(
                id: stage.id,
                title: stage.name,
                cards: cards
            )
            columns.append(column)
        }
    }
    
    @MainActor
    func selectFunnel(_ name: String) async throws {
        guard let funnel = state.funnels.first(where: { $0.name == name }) else { return }
        try await selectFunnel(funnel)
    }
    
    @MainActor
    func fetchFunnels(_ selection: String) async throws {
        let funnels = try await Networking.api.getFunnels()
        guard !funnels.isEmpty else { return }
        if let selectedFunnel = funnels.first(where: { $0.name == selection }) {
            try await selectFunnel(selectedFunnel)
        } else if let first = funnels.first {
            try await selectFunnel(first)
        }
        state.funnels = funnels
    }
    
    @MainActor
    func createDefaultFunnels() async throws {
        try await Networking.api.createDefaultFunnels()
        try await fetchFunnels("Leads")
    }
    
    @MainActor
    func assignCard(id: String, to stage: String) async throws {
        switch state.selectedFunnel?.type {
        case .case: _ = try await Networking.api.assignCaseToFunnelStage(id: id, stageID: stage)
        case .lead: _ = try await Networking.api.assignLeadToFunnelStage(id: id, stageID: stage)
        case .opportunity: _ = try await Networking.api.assignOpportunityToFunnelStage(id: id, stageID: stage)
        case .none: Logger.error("Assigned card to stage without selected funnel")
        }
    }
}
