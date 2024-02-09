//
//  MenuFAB.swift
//  iosApp
//
//  Created by Jared Warren on 2/8/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import SwiftUI

struct MenuFAB: View {
    let items: [MenuFABItem]
    @EnvironmentObject var appState: AppState

    struct MenuFABItem {
        let name: String
        let iconName: String
        let action: () -> Void
    }
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                fab
                .padding([.bottom, .trailing])
            }
        }
    }
    
    
    private var fab: some View {
        VStack(alignment: .trailing) {
            ForEach(items.indices, id: \.self) { i in
                let item = items[i]
                Button {
                    item.action()
                    appState.isFABExpanded.toggle()
                } label: {
                    FunnelminkGradient()
                        .mask {
                            HStack {
                                Image(systemName: item.iconName)
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text(item.name)
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .bold()
                        }
                        .frame(width: 200, height: 44)
                }
                .opacity(appState.isFABExpanded ? 1 : 0)
                .animation(.spring(), value: appState.isFABExpanded)
            }
            
            
            Button(action: {
                withAnimation {
                    self.appState.isFABExpanded.toggle()
                }
            }) {
                Image(systemName: appState.isFABExpanded ? "minus" : "plus")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .padding()
                    .frame(width: 50)
                    .background(FunnelminkGradient())
                    .foregroundStyle(Color.white)
                    .clipShape(Circle())
                    .rotationEffect(appState.isFABExpanded ? .degrees(180) : .degrees(0))
                    .animation(.spring(), value: appState.isFABExpanded)
            }
        }
        .onDisappear {
            appState.isFABExpanded = false
        }
    }
}


#Preview {
    MenuFAB(items: [
        .init(name: "Add", iconName: "plus") {
            print("Add")
        },
        .init(name: "Edit", iconName: "pencil") {
            print("Edit")
        },
        .init(name: "Delete", iconName: "trash") {
            print("Delete")
        }
    ])
    .withPreviewDependencies()
}
