//
//  MenuFAB.swift
//  iosApp
//
//  Created by Jared Warren on 2/8/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import SwiftUI

struct MenuFAB: View {
    let menuItems: [MenuItem]
    @State private var isExpanded = false
    
    var body: some View {
        VStack {
            ForEach(menuItems.indices, id: \.self) { i in
                let item = menuItems[i]
                Button(action: item.action) {
                    LoginBackgroundGradient()
                        .mask {
                            HStack {
                                Image(systemName: item.iconName)
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text(item.name)
                            }
                            .bold()
                        }
                        .frame(width: 120 ,height: 44)
                }
                .transition(.move(edge: .bottom))
                .opacity(isExpanded ? 1 : 0)
                .animation(.spring(), value: isExpanded)
            }
            
            
            Button(action: {
                withAnimation {
                    self.isExpanded.toggle()
                }
            }) {
                Image(systemName: isExpanded ? "minus" : "plus")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .padding()
                    .frame(width: 44)
                    .background(LoginBackgroundGradient())
                    .foregroundStyle(Color.white)
                    .clipShape(Circle())
                    .rotationEffect(isExpanded ? .degrees(180) : .degrees(0))
                    .animation(.spring(), value: isExpanded)
            }
        }
    }
    struct MenuItem {
        let name: String
        let iconName: String
        let action: () -> Void
    }
}


#Preview {
    Color.white.overlay {
        VStack {
            Spacer()
            HStack {
                Spacer()
                MenuFAB(menuItems: [
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
                .padding(.vertical)
            }
        }
    }
}
