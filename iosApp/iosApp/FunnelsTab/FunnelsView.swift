import SwiftUI

struct FunnelsView: View {
    @StateObject var viewModel = FunnelsViewModel()
    @ViewBuilder
    var body: some View {
        if FeatureFlags.funnelsTestUI.isEnabled {
            funnelsTestUI
        } else {
            originalUI
        }
    }
    
    var originalUI: some View {
        Text("Funnels")
            .navigationTitle("Funnels")
            .logged()
    }
    
    var funnelsTestUI: some View {
        VStack {
           Text("This is where some stuff goes")
            KanbanView(kanban: viewModel)
        }
        .navigationTitle("Funnels")
        .loggedTask { /* TODO: attach the viewModel somehow */ }
    }
}
