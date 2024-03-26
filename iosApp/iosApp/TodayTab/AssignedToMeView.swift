//
//  AssignedToMeView.swift
//  iosApp
//
//  Created by Jeremy Warren on 3/22/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import SwiftUI
import Shared

struct AssignedToMeView: View {
    @EnvironmentObject var navigation: Navigation
    @State var opportunities: [Opportunity] = []
    @State var leads: [Lead] = []
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    AssignedToMeView()
}
