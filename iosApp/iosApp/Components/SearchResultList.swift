//
//  UniversalSearchBar.swift
//  iosApp
//
//  Created by Jeremy Warren on 3/22/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import SwiftUI

struct SearchResultList: View {
    @EnvironmentObject var navigation: Navigation
    @State var searchText = ""
    @State var searchIsActive = false
    
    var body: some View {
                ScrollView {
                    HStack {
                        Button(action: {
                            navigation.popSegue()
                        }, label: {
                            Image(systemName: "chevron.left")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundStyle(.primary)
                        })
                        TextField("Search Tasks, Accounts, Cases, etc.", text: $searchText)
                            .submitLabel(.search)
                            .padding(.horizontal)
                            .overlay {
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke()
                                    .frame(height: 35)
                            }
                    }
                    .padding(.horizontal)
                }
                .navigationBarHidden(true)
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
    }
}

#Preview {
    SearchResultList()
}
