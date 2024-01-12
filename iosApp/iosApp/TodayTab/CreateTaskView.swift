//
//  CreateTaskView.swift
//  iosApp
//
//  Created by Jared Warren on 1/11/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import SwiftUI

struct CreateTaskView: View {
    @EnvironmentObject var navigation: Navigation
    @ObservedObject var viewModel: TodayViewModel
    @State var createTaskName = ""
    var body: some View {
        VStack {
            Spacer()
            Text("Create Task")
                .font(.title)
                .fontWeight(.bold)
            Color
                .clear
                .overlay {
                    if let errorMessage = viewModel.creationErrorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            VStack(spacing: 4) {
                HStack {
                    Text("Task name")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                TextField("", text: $createTaskName, prompt: Text("Place a call").foregroundColor(.gray))
                    .frame(height: 52)
                    .maxReadableWidth()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.black, lineWidth: 0.5))
                    .shadow(radius: 2)
                    .foregroundStyle(.black)
                    .keyboardType(.alphabet)
                    .autocorrectionDisabled()
                    .textContentType(.organizationName)
            }
            .padding(.vertical)
            AsyncButton {
                await viewModel.createTask(title: createTaskName, priority: 1, body: nil, scheduledDate: nil) {
                    navigation.dismissModal()
                }
            } label: {
                Text("Create")
                    .frame(height: 52)
                    .maxReadableWidth()
                    .background(LoginBackgroundGradient())
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            .multilineTextAlignment(.leading)
            Color.clear
        }
        .padding()
        .multilineTextAlignment(.center)
    }
}

#Preview {
    CreateTaskView(viewModel: .init())
}
