//
//  UniversalSearchBar.swift
//  iosApp
//
//  Created by Jeremy Warren on 3/22/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Shared
import SwiftUI

struct SearchResultList: View {
    @EnvironmentObject var navigation: Navigation
    @State var searchText = ""
    @State var searchIsActive = false
    @State var result = SearchResult(accounts: [], contacts: [], cases: [], leads: [], opportunities: [], tasks: [])
    
    var body: some View {
                ScrollView {
                    HStack {
                        Button(action: {
                            navigation.popSegue()
                        }, label: {
                            Image(systemName: "chevron.left")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundStyle(.primary)
                        })
                        TextField("Search Tasks, Accounts, Cases, etc.", text: $searchText)
                            .submitLabel(.search)
                            .padding(.horizontal)
                            .onSubmit {
                                Task {
                                    let body = SearchRequest(searchText: searchText)
                                    let searchResult = try await Networking.api.search(body: body)
                                    self.result = searchResult
                                }
                            }
                            .overlay {
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke()
                                    .frame(height: 35)
                            }
                    }
                    .padding(.horizontal)
                    if !result.cases.isEmpty {
                        Section("Cases") {
                            ForEach(result.cases, id: \.self) { caseRecord in
                                Button {
                                    navigation.segue(.caseDetails(caseRecord: caseRecord))
                                } label: {
                                    CustomCell(title: caseRecord.name, cellType: .navigation)
                                }
                            }
                        }
                    }
                    
                    if !result.opportunities.isEmpty {
                        Section("Opportunities") {
                            ForEach(result.opportunities, id: \.self) { opportunity in
                                Button {
                                    navigation.segue(.opportunityDetails(opportunity: opportunity))
                                } label: {
                                    CustomCell(title: opportunity.name, cellType: .navigation)
                                }
                            }
                        }
                    }
                    
                    if !result.leads.isEmpty {
                        Section("Leads") {
                            ForEach(result.leads, id: \.self) { lead in
                                Button {
                                    navigation.segue(.leadDetails(lead: lead))
                                } label: {
                                    CustomCell(title: lead.name, cellType: .navigation)
                                }
                            }
                        }
                    }
                }
                .navigationBarHidden(true)
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
    }
}

#Preview {
    SearchResultList()
}
