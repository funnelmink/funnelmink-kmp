//
//  UpdateWallView.swift
//  iosApp
//
//  Created by Jared Warren on 1/23/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import FirebaseRemoteConfig
import SwiftUI

struct UpdateWallView: View {
    @EnvironmentObject var appState: AppState
    var isSkippable: Bool {
        guard let minRequired = rc["iOS_updateWall_minVersionRequired"].stringValue, !minRequired.isEmpty else { return false }
        return !(Properties.appVersion.compare(minRequired, options: .numeric) == .orderedAscending)
        
    }
    let rc = RemoteConfig.remoteConfig()
    var title: String { rc["iOS_updateWall_title"].stringValue ?? "funnelmink just got even better" }
    var message: String { rc["iOS_updateWall_body"].stringValue ?? "Tap the button to update to the latest version!" }
    var imageURL: String { rc["iOS_updateWall_imageURL"].stringValue ?? "https://placehold.co/600" }
    var buttonTitle: String { rc["iOS_updateWall_buttonTitle"].stringValue ?? "Update" }
    var buttonURL: String { rc["iOS_updateWall_buttonURL"].stringValue ?? "itms-apps://apps.apple.com/us/app/6472970682" }
    
    
    var body: some View {
        VStack {
            Spacer()
            
            AsyncImage(url: URL(string: imageURL))
            .aspectRatio(contentMode: .fit)
            .padding()
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top)
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.bottom)
            
            Spacer()
            
            Button {
                Navigation.shared.externalDeeplink(to: buttonURL)
            } label: {
                Text(buttonTitle)
                    .frame(height: 52)
                    .maxReadableWidth()
                    .background(FunnelminkGradient())
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            .padding()
            if isSkippable {
                Button {
                    appState.shouldPresentUpdateWall = false
                } label: {
                    Text("Later")
                        .bold()
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom)
            }
            
            Spacer()
        }
        .logged()
    }
}
