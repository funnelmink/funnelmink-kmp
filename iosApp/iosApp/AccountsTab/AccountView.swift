//
//  AccountView.swift
//  iosApp
//
//  Created by Jeremy Warren on 1/13/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import SwiftUI
import Shared
import UIKit

struct AccountView: View {
    @EnvironmentObject var nav: Navigation
    @StateObject var viewModel = AccountsViewModel()
    @State private var isAnimating: Bool = false
    @State private var showingActionSheet = false
    
    var account: Account
    var initials: String {
        
        if let initial = account.name.first {
            return String(initial)
        } else {
            return ""
        }
    }
    
     private func makeCall(phoneNumber: String) {
        guard let url = URL(string: "tel://\(phoneNumber)"),
              UIApplication.shared.canOpenURL(url) else {
            print("Cannot make this call")
            return
        }

        UIApplication.shared.open(url)
    }
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .stroke(Gradient(colors: [.blue, .teal, .mint]), lineWidth: 10)
                    .frame(width: 175, height: 175)
                
                Text(initials)
                    .bold().font(.system(size: 80))
            }
            Text(account.name)
                .bold()
                .font(.title)
            Text(account.name) // accounts don't have a company name anymore because they *are* the company
                .foregroundStyle(.secondary)
        }
        Spacer()
        ScrollView {
            Button(action: {
                showingActionSheet = true
            }, label: {
                CustomCell(title: "Phone", subtitle: account.phone, icon: "phone" ,cellType: .iconAction)
                    .padding()
            })
            .foregroundStyle(.primary)
            .actionSheet(isPresented: $showingActionSheet) {
                        ActionSheet(
                            title: Text("Account"),
                            message: Text("Call \(account.phone ?? "")?"),
                            buttons: [
                                .default(Text("Call")) {
                                    guard let phoneNumber = account.phone else { return }
                                    makeCall(phoneNumber: phoneNumber)
                                },
                                .cancel()
                            ]
                        )
                    }
            Button(action: {
                // present a banner to send an email
            }, label: {
                CustomCell(title: "Email", subtitle: account.email, icon: "envelope" ,cellType: .iconAction)
                    .padding()
            })
            .foregroundStyle(.primary)
            Button(action: {
                // present a banner to route to an address
            }, label: {
                CustomCell(title: "Address", subtitle: "891 N 800 E, Orem, UT              ", icon: "arrow.merge" ,cellType: .iconAction)
                    .padding()
            })
            .foregroundStyle(.primary)
        }
        .padding()
        
        
    }
}
