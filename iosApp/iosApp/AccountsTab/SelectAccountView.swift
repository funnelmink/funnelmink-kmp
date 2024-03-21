//
//  SelectAccountView.swift
//  iosApp
//
//  Created by Jared Warren on 3/21/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Shared
import SwiftUI

struct SelectAccountView: View {
    let nextView: (_ accountID: String) -> Void
    @State var accounts: [Account] = []
    var body: some View {
        VStack {
            Text("Select an account")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            List(accounts, id: \.id) { account in
                Button {
                    nextView(account.id)
                } label: {
                    CustomCell(title: account.name, cellType: .navigation)
                        .foregroundStyle(Color.primary)
                }
            }
        }
        .loggedTask {
            do {
                accounts = try await Networking.api.getAccounts()
            } catch {
                Toast.error(error)
            }
        }
    }
}

#Preview {
    SelectAccountView() { _ in }
}
