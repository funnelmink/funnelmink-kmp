//
//  CustomTextField.swift
//  FunnelMinkViews
//
//  Created by Jeremy Warren on 12/28/23.
//

import SwiftUI

enum TextFieldStyle {
    case text
    case email
    case password
    case phone
    case date
    case dateTime
    case search
    case decimal
    case integer
    case iban
    case cvv
    case creditCard
    case pin
}

struct CustomTextField: View {
    @Binding var text: String
    @State var passwordIsHidden: Bool = true
    var placeholder: String
    var style: TextFieldStyle
    var icon: String?
    var hasHelperText: Bool = false
    
    
    var body: some View {
        switch style {
        case .text,
                .email,
                .phone,
                .date,
                .dateTime,
                .search,
                .decimal,
                .integer,
                .iban,
                .cvv,
                .creditCard,
                .pin:
            textFieldForStyle()
                .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                .frame(height: 50)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke()
                        .foregroundStyle(.gray).opacity(0.4)
                }
                .padding(4)
        case .password:
            HStack {
                if passwordIsHidden {
                    SecureField(placeholder, text: $text)
                        .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                        .frame(height: 50)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke()
                                .foregroundStyle(.gray).opacity(0.4)
                        }
                        .padding(4)
                } else {
                    TextField(placeholder, text: $text)
                        .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                        .frame(height: 50)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke()
                                .foregroundStyle(.gray).opacity(0.4)
                        }
                        .padding(4)
                }
                Button {
                    passwordIsHidden.toggle()
                } label: {
                    Image(systemName: passwordIsHidden ? "eye" : "eye.slash")
                        .foregroundColor(.black)
                }
                
            }
        }
    }
    
    @ViewBuilder
    private func textFieldForStyle() -> some View {
        switch style {
        case .text:
            HStack {
                TextField(placeholder, text: $text)
                if let icon {
                    Image(systemName: icon)
                }
            }
        case .email:
            HStack {
                TextField("Email", text: $text)
                    .keyboardType(.emailAddress)
                if let icon {
                    Image(systemName: icon)
                }
            }
        case .phone:
            HStack {
                TextField("Phone", text: $text)
                    .keyboardType(.phonePad)
                if let icon {
                    Image(systemName: icon)
                }
            }
        case .date:
            HStack {
                TextField("Date", text: $text)
                if let icon {
                    Image(systemName: icon)
                }
            }
        case .dateTime:
            HStack {
                TextField("Date Time", text: $text)
                if let icon {
                    Image(systemName: icon)
                }
            }
        case .search:
            HStack {
                TextField("Search", text: $text)
                    .keyboardType(.webSearch)
                if let icon {
                    Image(systemName: icon)
                }
            }
        case .decimal:
            HStack {
                TextField(placeholder, text: $text)
                    .keyboardType(.decimalPad)
                if let icon {
                    Image(systemName: icon)
                }
            }
        case .integer:
            HStack {
                TextField(placeholder, text: $text)
                    .keyboardType(.numberPad)
                if let icon {
                    Image(systemName: icon)
                }
            }
        case .iban:
            HStack {
                TextField("IBAN", text: $text)
                if let icon {
                    Image(systemName: icon)
                }
            }
        case .cvv:
            HStack {
                TextField("CVV", text: $text)
                    .keyboardType(.numberPad)
                if let icon {
                    Image(systemName: icon)
                }
            }
        case .creditCard:
            HStack {
                TextField("Credit Card", text: $text)
                    .keyboardType(.numberPad)
                if let icon {
                    Image(systemName: icon)
                }
            }
        case .pin:
            HStack {
                TextField("PIN", text: $text)
                    .keyboardType(.numberPad)
                if let icon {
                    Image(systemName: icon)
                }
            }
        case .password:
            EmptyView()
        }
    }
}

#Preview {
    struct Preview: View {
        @State private var text: String = ""
        var body: some View {
            VStack {
                CustomTextField(text: $text, placeholder: "Placeholder", style: .text)
                CustomTextField(text: $text, placeholder: "Password", style: .password)
                CustomTextField(text: $text, placeholder: "Password", style: .date, icon: "calendar")
                CustomTextField(text: $text, placeholder: "Password", style: .email, icon: "envelope")
                CustomTextField(text: $text, placeholder: "Password", style: .phone, icon: "phone")
                CustomTextField(text: $text, placeholder: "Password", style: .search, icon: "magnifyingglass")
            }
            .padding()
        }
    }
    
    return Preview()
}
