//
//  NavigationSearchView.swift
//  iosApp
//
//  Created by Jeremy Warren on 3/22/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import SwiftUI

struct NavigationSearchView: View {
    var action: () = ()
    
    var body: some View {
        HStack {
            Image(systemName: "circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
            Spacer()
            Button(action: {
                    action
            }, label: {
                FunnelminkGradient().mask(
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                )
                .frame(width: 24, height: 24)
            })
            Image(systemName: "person")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
        }
        .padding(.horizontal)
    }
}

#Preview {
    NavigationSearchView()
}
