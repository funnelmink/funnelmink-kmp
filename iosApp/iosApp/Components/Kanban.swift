//
//  Kanban.swift
//  iosApp
//
//  Created by Jared Warren on 1/26/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - Views

struct KanbanView<Kanban: KanbanViewModel>: View {
    @ObservedObject var kanban: Kanban
    let onCardTap: (KanbanCard) -> Void
    var body: some View {
        GeometryReader { o_o in
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    Spacer(minLength: o_o.size.width * 0.1)
                    ForEach(kanban.columns) { column in
                        KanbanColumnView(kanban: kanban, column: column, onCardTap: onCardTap)
                    }
                    .frame(width: o_o.size.width * 0.8)
                    Spacer(minLength: o_o.size.width * 0.1)
                }
            }
            .scrollIndicators(.never)
            .background(Color(.systemGroupedBackground), ignoresSafeAreaEdges: .all)
        }
    }
}

struct KanbanColumnView<Kanban: KanbanViewModel>: View {
    @ObservedObject var kanban: Kanban
    @ObservedObject var column: KanbanColumn
    let onCardTap: (KanbanCard) -> Void
    var body: some View {
        VStack(spacing: 0) {
            Text(column.title)
            List {
                if column.cards.isEmpty {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray2), lineWidth: 1)
                            .frame(height: 100)
                        Text("Empty")
                    }
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .listRowBackground(Color.clear)
                        .onDrop(
                            of: [.text],
                            delegate: KanbanDropDelegate(kanban: kanban, destinationColumn: column)
                        )
                } else {
                    ForEach(column.cards) { KanbanCardView(card: $0, onTap: onCardTap) }
                        .onDrop(
                            of: [.text],
                            delegate: KanbanDropDelegate(kanban: kanban, destinationColumn: column)
                        )
                }
            }
        }
    }
}

struct KanbanCardView: View {
    @Environment(\.colorScheme) var colorScheme
    let card: KanbanCard
    let onTap: (KanbanCard) -> Void
    var body: some View {
        VStack(alignment: .leading) {
            Text(card.title)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            label(card.subtitleLabel)
                .padding(.vertical, 1)
            HStack(spacing: 12) {
                label(card.footerLabel)
                if let secondFooterLabel = card.secondFooterLabel {
                    label(secondFooterLabel)
                }
                Spacer()
                Text(card.footerTrailingText)
                    .font(.headline)
            }
        }
        .font(.subheadline)
        .padding()
        .background(
            colorScheme == .light ? Color.white : Color(.systemGray4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .listRowSeparator(.hidden)
        .listRowInsets(.init(top: 0, leading: 0, bottom: 8, trailing: 0))
        .listRowBackground(Color.white.opacity(0.001))
        .onDrag { NSItemProvider(object: card.asNSString) }
        .onTapGesture { onTap(card) }
    }
    
    func label(_ label: KanbanCard.Label) -> some View {
        HStack(spacing: 2) {
            Image(systemName: label.iconName)
            Text(label.text)
        }
        .foregroundStyle(.secondary)
    }
}

// MARK: - Business Logic

protocol KanbanViewModel: ObservableObject {
    var columns: [KanbanColumn] { get set }
}

struct KanbanDropDelegate: DropDelegate {
    let kanban: any KanbanViewModel
    let destinationColumn: KanbanColumn
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        if info.itemProviders(for: [.text]).isEmpty {
            return nil
        }
        return DropProposal(operation: .copy)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        let items = info.itemProviders(for: [.text])
        guard !items.isEmpty else { fatalError() }
        for item in items {
            _ = item.loadObject(ofClass: String.self) { string, _ in
                DispatchQueue.main.async {
                    guard let data = string?.data(using: .utf8),
                            var card = try? JSONDecoder().decode(KanbanCard.self, from: data)
                            // TODO: error handling
                    else { return }
                    
                    // make sure the destination is a new column
                    guard card.columnID != destinationColumn.id else { return }
                    
                    // find original column
                    guard let sourceColumn = kanban.columns.first(where: { $0.id == card.columnID }) else { return }
                    
                    // remove card from original column
                    sourceColumn.cards.removeAll(where: { $0.id == card.id })
                    
                    // update card and move to destination
                    card.columnID = destinationColumn.id
                    destinationColumn.cards.insert(card, at: 0)
                }
            }
        }
        return true
    }
}

class KanbanColumn: ObservableObject, Identifiable {
    let id: String
    let title: String
    @Published var cards: [KanbanCard]
    
    init(id: String, title: String, cards: [KanbanCard]) {
        self.id = id
        self.title = title
        self.cards = cards
    }
}

// MARK: - Model

struct KanbanCard: Identifiable, Codable {
    let id: String
    let title: String
    let subtitleLabel: Label
    let footerLabel: Label
    var secondFooterLabel: Label?
    let footerTrailingText: String
    
    var columnID: String
    
    struct Label: Codable {
        let iconName: String
        let text: String
    }
    
    var asNSString: NSString {
        do {
            let data = try JSONEncoder().encode(self)
            return (String(data: data, encoding: .utf8) ?? "") as NSString
        } catch {
            // TODO: error handling
            return ""
        }
    }
}
