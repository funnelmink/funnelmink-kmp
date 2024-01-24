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
                guard let url = URL(string: buttonURL) else { return }
                UIApplication.shared.open(url)
            } label: {
                Text(buttonTitle)
                    .frame(height: 52)
                    .maxReadableWidth()
                    .background(LoginBackgroundGradient())
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            .padding()
            
            Spacer()
        }
    }
}

#Preview {
    UpdateWallView()
}
