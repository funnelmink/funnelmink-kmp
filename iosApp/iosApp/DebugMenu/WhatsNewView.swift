//
//  WhatsNewView.swift
//  iosApp
//
//  Created by Jared Warren on 1/23/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import FirebaseRemoteConfig
import Shared
import SwiftUI

struct WhatsNewView: View {
    @EnvironmentObject var appState: AppState
    @State var selection: Int = 0
    @State var whatsNewData: [WhatsNewData] = []
    
    init() {
        UIPageControl.appearance().currentPageIndicatorTintColor = .systemBlue
        UIPageControl.appearance().pageIndicatorTintColor = .systemGray
    }
    
    var body: some View {
        TabView(selection: $selection) {
            ForEach(whatsNewData.indices, id: \.self) { i in
                let data = whatsNewData[i]
                VStack {
                    Text(data.title)
                        .font(.title)
                        .bold()
                        .padding(.bottom)
                    Text(data.body)
                        .font(.body)
                        .padding(.bottom)
                    if let url = URL(string: data.imageURL) {
                        AsyncImage(url: url) { phase in phase.image?.resizable() }
                            .aspectRatio(contentMode: .fit)
                            .padding()
                    }
                }
                .padding()
                .tag(i)
            }
        }
        .tabViewStyle(.page)
        .foregroundStyle(.primary)
        .overlay {
            if selection == whatsNewData.count - 1 {
                VStack {
                    HStack {
                        Spacer()
                        Button("Dismiss") {
                            let key = "iOS_whatsNew_version"
                            let viewedVersion = RemoteConfig.remoteConfig()["iOS_whatsNew_version"].numberValue.intValue
                            UserDefaults.standard.set(viewedVersion, forKey: key)
                            appState.shouldPresentWhatsNew = false
                        }
                        .padding(.trailing)
                    }
                    Spacer()
                }
            }
        }
        .loggedOnAppear {
            let rc = RemoteConfig.remoteConfig()
            let views = rc["iOS_whatsNew_views"].stringValue
            if let data = views?.data(using: .utf8),
               let whatsNew = try? JSONDecoder().decode([WhatsNewData].self, from: data),
               !whatsNew.isEmpty{
                whatsNewData = whatsNew
            } else {
                Logger.error("What's New View was presented without any views to display! Dismissing early.")
                appState.shouldPresentUpdateWall = false
            }
        }
    }
}

struct WhatsNewData: Codable {
    let title: String
    let body: String
    let imageURL: String
}
