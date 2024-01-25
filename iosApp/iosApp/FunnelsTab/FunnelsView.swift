import SwiftUI

struct FunnelsView: View {
    @State var index = 0
    @State var isDragging = false
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
            GeometryReader { geo in
                let itemWidth = geo.size.width * 0.8
                Carousel(index: $index, isDragging: $isDragging, items: 0..<3, itemWidth: itemWidth) { i in
                    [Color.blue, .red, .green][i]
                        .aspectRatio(0.66, contentMode: .fit)
                        .frame(width: itemWidth)
                        .padding()
                }
            }
        }
        .navigationTitle("Funnels")
        .loggedTask { /* TODO: attach the viewModel somehow */ }
    }
}
