//
//  LoginView.swift
//  funnelmink
//
//  Created by Jared Warren on 11/28/23.
//  Copyright © 2023 FunnelMink, LLC. All rights reserved.
//

import AuthenticationServices
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var navigation: Navigation
    @StateObject var viewModel = LoginViewModel()
    let buttonWidths: CGFloat = 280
    let buttonHeights: CGFloat = 50
    
    var body: some View {
        VStack {
            Spacer()
            Spacer()
            Image("logo.with.text")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.horizontal)
                .frame(width: buttonWidths)
            Spacer()
            
            // https://firebase.google.com/docs/auth/ios/apple
            Button {
                appState.todo()
            } label: {
                HStack {
                    Text("")
                        .font(.title)
                        .padding(.trailing, 8)
                    Text("Continue with Apple")
                }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(.systemBackground))
                    .frame(width: buttonWidths, height: buttonHeights)
                    .background(Color(.label), in: Capsule())
            }
            
            // https://serg-ios.github.io/2021-03-10-my-vocabulary-google-signin/
            Button {
                Task {
                    await viewModel.signInWithGoogle()
                }
            } label: {
                // https://developers.google.com/identity/branding-guidelines?hl=es-419
                Image("continue.with.google")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: buttonWidths, height: buttonHeights)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color(.label).opacity(0.0625))
                    )
            }
            .background(Color(hex: "f2f2f2"), in: Capsule())

            Spacer()
            HStack(spacing: 24) {
                Button("Privacy Policy") { appState.todo() }
                Button("Terms of Service") { appState.todo() }
            }
            .font(.callout.bold())
        }
        .maxReadableWidth()
        .padding()
    }
}

#Preview {
    LoginView()
}
