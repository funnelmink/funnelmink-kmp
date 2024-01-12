//
//  CreateTaskView.swift
//  iosApp
//
//  Created by Jared Warren on 1/11/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import SwiftUI

struct CreateTaskView: View {
    @ObservedObject var viewModel: TodayViewModel
    var body: some View {
        Text("Hello, World!")
    }
}

#Preview {
    CreateTaskView(viewModel: .init())
}
