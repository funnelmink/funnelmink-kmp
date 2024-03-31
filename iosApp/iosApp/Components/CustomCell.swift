//
//  CustomCell.swift
//  FunnelMinkViews
//
//  Created by Jeremy Warren on 12/21/23.
//

import SwiftUI

enum CellType {
    case navigation
    case switchControl
    case checkbox
    case radio
    case informative
    case iconAction
}

struct CustomCell: View {
    @State var switchIsOn = false
    @State var isChecked = false
    @State var radioButton = false
    var title: String
    var subtitle: String?
    var description: String?
    var detail: String?
    var icon: String?
    var isDisabled: Bool = false
    var needsBorder: Bool = false
    var cellType: CellType
    
    var body: some View {
        HStack(spacing: 15) {
            if let icon {
                if self.cellType != .iconAction {
                    Image(systemName: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .bold()
                
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                if let description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            if let detail {
                Text(detail)
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundColor(.secondary)
            }
            switch cellType {
            case .navigation:
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            case .switchControl:
                Toggle("", isOn: $switchIsOn)
            case .checkbox:
                Checkbox(isChecked: $isChecked)
            case .radio:
                RadioButton(isSelected: $radioButton)
            case .informative:
                EmptyView()
            case .iconAction:
                Image(systemName: icon ?? "person")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.vertical, 8)
        .overlay(
            RoundedRectangle(cornerRadius: 0)
                .stroke(needsBorder ? Color.gray : Color.clear, lineWidth: 1)
        )
    }
}

struct Checkbox: View {
    @Binding var isChecked: Bool
    
    var body: some View {
        Image(systemName: isChecked ? "checkmark.square" : "square")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
            .onTapGesture {
                withAnimation {
                    self.isChecked.toggle()
                }
            }
            .foregroundColor(isChecked ? .blue : .gray)
        
    }
}

struct RadioButton: View {
    @Binding var isSelected: Bool
    
    var body: some View {
        Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
            .onTapGesture {
                withAnimation {
                    self.isSelected.toggle()
                }
            }
            .foregroundColor(isSelected ? .blue : .gray)
    }
}

#Preview {
    Section {
        CustomCell(title: "Title", needsBorder: true, cellType: .navigation)
        CustomCell(title: "Title", icon: "person", cellType: .checkbox)
        CustomCell(title: "Title", subtitle: "Subtitle", icon: "person", cellType: .informative)
        CustomCell(title: "Title", subtitle: "Subtitle", description: "891 N 800 E", icon: "person", cellType: .radio)
        CustomCell(title: "Title", subtitle: "Subtitle", description: "891 N 800 E", detail: "Meeting Today", icon: "person", cellType: .switchControl)
        
    }
}
