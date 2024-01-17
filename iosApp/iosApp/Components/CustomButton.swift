//
//  CustomButton.swift
//  FunnelMinkViews
//
//  Created by Jeremy Warren on 12/22/23.
//

import SwiftUI

enum ButtonType {
    case primary
    case secondary
    case destructive
}


struct CustomButton: View {
    var isDisabled: Bool = false
    var buttonType: ButtonType
    var buttonText: String
    var action: () -> Void
    
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
           foregroundText
                .frame(height: 56)
                .frame(minWidth: 80)
                .background(background)
        })
    }
    
    
    @ViewBuilder var background: some View {
        switch buttonType {
        case .primary:
                RoundedRectangle(cornerRadius: 6)
                .fill(Color.blue)
        case .secondary:
        RoundedRectangle(cornerRadius: 6)
                .stroke(Color.blue)
        case .destructive:
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.red)
        }
    }
    @ViewBuilder var foregroundText: some View {
        switch buttonType {
        case .primary:
            Text(buttonText)
                .foregroundStyle(Color.white)
        case .secondary:
            Text(buttonText)
                .foregroundStyle(Color.blue)
        case .destructive:
            Text(buttonText)
                .foregroundStyle(Color.white)
        }
    }
}

#Preview {
    VStack {
        CustomButton(buttonType: .primary, buttonText: "Testing"){}
        CustomButton(buttonType: .secondary, buttonText: "Testing"){}
        CustomButton(buttonType: .destructive, buttonText: "Testing"){}
    }
}
