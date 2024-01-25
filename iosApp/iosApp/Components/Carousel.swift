//
//  Carousel.swift
//  iosApp
//
//  Created by Jared Warren on 1/24/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import SwiftUI

struct Carousel<Data, Content>: View where Data: RandomAccessCollection, Data.Index: Hashable, Content: View {
    @Binding var index: Int // would be nice to use Data.Index here instead of Int
    @Binding var isDragging: Bool
    @State private var offsetX: CGFloat = 0

    let items: Data
    let itemWidth: CGFloat
    let content: (Data.Element) -> Content
    private let feedbackGenerator = UISelectionFeedbackGenerator()

    init(index: Binding<Int>, isDragging: Binding<Bool>, items: Data, itemWidth: CGFloat, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        _index = index
        _isDragging = isDragging
        self.items = items
        self.itemWidth = itemWidth
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            LazyHStack(alignment: .center, spacing: 0) {
                ForEach(items.indices, id: \.self) { index in
                    content(items[index])
                        .frame(width: itemWidth)
                }
            }
            .padding(.horizontal, (geometry.size.width - itemWidth) / 2)
            .offset(x: offsetX)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offsetX = value.translation.width - CGFloat(index) * itemWidth
                        isDragging = true
                    }
                    .onEnded { value in
                        let speedThreshold: CGFloat = 400 // if the final velocity is below threshold, treat as a drag (snap in place) instead of swipe
                        if abs(value.predictedEndLocation.x - value.location.x) < speedThreshold {
                            let indexOffset = Int(round(offsetX / -itemWidth))
                            index = max(0, min(items.count - 1, indexOffset))
                        } else {
                            let predictedEndOffset = value.predictedEndTranslation.width + offsetX
                            let predictedIndexOffset = Int(round(predictedEndOffset / -itemWidth))
                            index = max(0, min(items.count - 1, predictedIndexOffset))
                        }
                        isDragging = false
                        withAnimation(.spring()) {
                            offsetX = CGFloat(index) * -itemWidth
                        }
                    }
            )
            .onChange(of: index) { newIndex in
                withAnimation(.spring()) {
                    offsetX = CGFloat(newIndex) * -itemWidth
                }
                feedbackGenerator.selectionChanged()
            }
            .onAppear {
                offsetX = -CGFloat(index) * itemWidth
                isDragging = false
            }
        }
    }
}
