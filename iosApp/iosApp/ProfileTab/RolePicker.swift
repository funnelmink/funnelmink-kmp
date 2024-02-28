//
//  RolePicker.swift
//  iosApp
//
//  Created by Jared Warren on 2/28/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Shared
import SwiftUI

struct RolePicker: View {
    @Binding var roles: [WorkspaceMembershipRole]
    var body: some View {
        List {
            ForEach(WorkspaceMembershipRole.allCases, id: \.self) { role in
                HStack {
                    Text(role.name)
                    Spacer()
                    if roles.contains(role) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if roles.contains(role) {
                        roles.removeAll(where: { $0 == role })
                    } else {
                        roles.append(role)
                    }
                }
            }
        }
    }
}

#Preview {
    RolePicker(roles: .constant([.admin]))
}
