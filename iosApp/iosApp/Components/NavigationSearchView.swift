//
//  NavigationSearchView.swift
//  iosApp
//
//  Created by Jeremy Warren on 3/22/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import SwiftUI

struct NavigationSearchView: View {
    @EnvironmentObject var navigation: Navigation
    
    var body: some View {
        HStack {
            if navigation._canDisplayFAB {
                Image(.logoWithText)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 24, height: 24)
                    .padding(.leading)
            }
            Spacer()
            Button(action: {
                navigation.segue(.searchResultList)
            }, label: {
                FunnelminkGradient().mask(
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                )
                .frame(width: 24, height: 24)
            })
            Button {
                navigation.segue(.settings)
            } label: {
                FunnelminkGradient().mask(
                    Image(systemName: "gearshape")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                )
                .frame(width: 24, height: 24)
                
            }

        }
    }
}

#Preview {
    NavigationSearchView()
}
