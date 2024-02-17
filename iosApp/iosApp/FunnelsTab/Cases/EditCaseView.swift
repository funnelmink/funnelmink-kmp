//
//  EditCaseView.swift
//  iosApp
//
//  Created by Jared Warren on 2/9/24.
//  Copyright © 2024 orgName. All rights reserved.
//

import Shared
import SwiftUI

struct EditCaseView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var navigation: Navigation
    @StateObject var viewModel = EditCaseViewModel()
    
    @State private var assignedTo = ""
    @State private var closedDate = ""
    @State private var description = ""
    @State private var name = ""
    @State private var notes = ""
    @State private var priority: Int32 = 0
    @State private var stageID = ""
    @State private var value = ""
    
    @State private var shouldDisplayRequiredIndicators = false
    
    var caseRecord: CaseRecord?
    var initialFunnelD: String?
    var initialStageID: String?
    var accountID: String?
    
    var body: some View {
        VStack {
            
        }
        .loggedTask {
            if let caseRecord {
                name = caseRecord.name
                description = caseRecord.description_ ?? ""
                assignedTo = caseRecord.assignedTo ?? ""
                priority = caseRecord.priority
                notes = caseRecord.notes ?? ""
                value = "\(caseRecord.value)"
                closedDate = caseRecord.closedDate ?? ""
                stageID = caseRecord.stageID ?? ""
            }
        }
    }
}

#Preview {
    EditCaseView()
}
