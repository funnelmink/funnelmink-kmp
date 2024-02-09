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
        var isInitialized = false
        var selectedFunnel: Funnel?
    }
    
    @MainActor
    func setUp(initialSelection: String) async throws {
        if !state.isInitialized {
            try await fetchFunnels()
        }
    }
    
    @MainActor
    func selectFunnel(_ funnel: Funnel) async throws {
        columns.removeAll()
        self.state.selectedFunnel = funnel
        for stage in funnel.stages {
            var cards = [KanbanCard]()
            
            switch funnel.type {
            case .lead:
                for lead in funnel.leads {
                    let card = KanbanCard(
                        id: lead.id,
                        title: lead.name,
                        subtitleLabel: .init(iconName: "note.text", text: lead.notes ?? "--"),
                        footerLabel: .init(
                            iconName: lead.type == .individual ? "person" : "building.2",
                            text: lead.type.typeName
                        ),
                        secondFooterLabel: nil,
                        footerTrailingText: "",
                        columnID: lead.stage ?? stage.id
                    )
                    cards.append(card)
                }
            case .case:
                for caseRecord in funnel.cases {
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
                        columnID: caseRecord.stage ?? stage.id
                    )
                    cards.append(card)
                }
            case .opportunity:
                for opportunity in funnel.opportunities {
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
                        columnID: opportunity.stage ?? stage.id
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
    private func fetchFunnels() async throws {
        let funnels = try await Networking.api.getFunnels()
        try await selectFunnel(funnels.first!)
        var state = self.state
        state.funnels = funnels
        state.isInitialized = true
        self.state = state
    }
    
    @MainActor
    func createDefaultFunnels() async throws {
        try await Networking.api.createDefaultFunnels()
        try await fetchFunnels()
    }
}
