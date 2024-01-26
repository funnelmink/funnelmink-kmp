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
                    ScrollView {
                        ForEach(0..<10, id: \.self) { j in
                            ZStack {
                                Color.gray.overlay(
                                    Text("\(i) - \(j)")
                                )
                                .aspectRatio(2.4, contentMode: .fit)
                            }
                            .onDrag {
                                isDragging = true
                                return NSItemProvider(object: String(j) as NSString)
                            }
                        }
                    }
                    .scrollIndicators(.never)
                    .frame(width: itemWidth - 32)
                    .padding(.horizontal, 16)
                }
                .clipped()
            }
        }
        .navigationTitle("Funnels")
        .loggedTask { /* TODO: attach the viewModel somehow */ }
    }
}
