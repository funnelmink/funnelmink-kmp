import SwiftUI

struct FunnelsView: View {
    @StateObject var viewModel = FunnelsViewModel()
    @AppStorage(.storage.funnelsPickerSelection) var selection = "Leads"
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
        .toolbar {
            ToolbarItem {
                Picker("Funnels", selection: $selection) {
                    Text("Leads").tag("Leads")
                }
            }
        }
        .navigationTitle("Funnels")
        .loggedTask {
            do {
                try await viewModel.fetch()
                
                // TODO: if !fetchedFunnels.contains(selection) { selection = "Leads" }
            } catch {
                Toast.error(error)
            }
        }
    }
}
