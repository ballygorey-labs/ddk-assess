//
//  HistoryScreen.swift
//  Diadochokinetic Assess
//
//  Created by Collin Dunphy on 9/27/20.
//

import Algorithms
import SwiftUI

struct HistoryScreen: View {
    
    @EnvironmentObject var model : DDKModel
    
    @AppStorage(StorageKeys.History.useGroups) var useGroups: Bool = false
    @AppStorage(StorageKeys.History.sortBy) var sortBy: RecordSortTypes = .pinned
    
    @State private var recordEditSelection: AssessmentRecord? = nil
    
    @State private var recordDeleteSelection: AssessmentRecord? = nil
    @State private var showDeleteItemConfirmationAlert: Bool = false

    @State private var showDeleteAllConfirmationAlert: Bool = false
    
    
    // MARK: - Grouped Records
    // Sorts and labels sections of records appropriately.
    var groupedRecords : [RecordGroup]? {
        
        if model.allRecords.isEmpty {
            // No records to display..
            return nil
        }
        
        switch sortBy {
            
        case .pinned: // Group by Pinned
            return [
                RecordGroup(title: "Pinned", records: model.pinnedRecords),
                RecordGroup(records: model.records)
            ]
            
        case .date: // Group by Date
            
            let recordsByName = model.allRecords
                .chunked(by: {
                    $0.date.formatted(
                        date: .numeric,
                        time: .omitted
                    ) ==
                    $1.date.formatted(
                        date: .numeric,
                        time: .omitted
                    )
                })
            
            return recordsByName.map { (records) in
                RecordGroup(
                    title: records.first?.date.formatted(
                        date: .numeric,
                        time: .omitted
                    ),
                    records: Array(records)
                )
            }
            
        case .kind: // Group by Kind
            
            let recordsByKind = model.allRecords
                .sorted(by: { $0.type.rawValue < $1.type.rawValue })
                .chunked(on: \.type)
                        
            return recordsByKind.map { (type, records) in
                RecordGroup(
                    title: type.title,
                    records: Array(records)
                )
            }
        }
    }
    
    // MARK: - List
    var listOfRecords: some View {
        List {
            if useGroups {
                if let groupedRecords = groupedRecords {
                    // Iterate over the keys in the dictionary
                    ForEach(groupedRecords, id: \.title) { group in //TODO: Dict is inherently unordered. Find some way to keep this consistent.
                        if !group.records.isEmpty {
                            // Grouped Section with a Key and existent Records.
                            sectionOfRecordHistory(group.title, group.records)
                        }
                    }
                } else {
                    emptyHistory
                }
            } else {
                // Show all records by time, regardless of "GroupBy"
                if !model.allRecords.isEmpty {
                    sectionOfRecordHistory(nil, model.allRecords)
                } else {
                    emptyHistory
                }
            }
        }
    }
    
    //MARK: - Empty History
    var emptyHistory : some View {
        VStack {
            Image(systemName: "heart.text.square")
                .font(.system(size: 66))
                .imageScale(.large)
                .padding(.bottom, 8)
            
            Text("No Assessmenets")
                .font(.title3)
                .multilineTextAlignment(.center)
        }
        .foregroundColor(.secondary)
    }
    
    // MARK: - sectionOfRecordHistory
    /// Creates a section in the list and loops over the provided records
    /// - Parameters:
    ///   - header: Section title string, shown above the section of records
    ///   - records: Array of Records to loop over
    @ViewBuilder
    func sectionOfRecordHistory(_ header: String? = nil, _ records: [AssessmentRecord]) -> some View {
        
        // Check to see if header exists
        if let header = header {
            
            // Check to see if header has a value, if not, don't add a header to the section.
            if !header.isEmpty {
                Section(header) {
                    ForEach(records, id: \.id) { record in
                        RecordHistoryRow(
                            record: record,
                            recordEditSelection: $recordEditSelection,
                            recordDeleteSelection: $recordDeleteSelection,
                            showDeleteItemConfirmationAlert: $showDeleteItemConfirmationAlert
                        )
                    }
                }
            } else {
                Section {
                    ForEach(records, id: \.id) { record in
                        RecordHistoryRow(
                            record: record,
                            recordEditSelection: $recordEditSelection,
                            recordDeleteSelection: $recordDeleteSelection,
                            showDeleteItemConfirmationAlert: $showDeleteItemConfirmationAlert
                        )
                    }
                }
            }
            
        } else {
            Section {
                ForEach(records, id: \.id) { record in
                    RecordHistoryRow(
                        record: record,
                        recordEditSelection: $recordEditSelection,
                        recordDeleteSelection: $recordDeleteSelection,
                        showDeleteItemConfirmationAlert: $showDeleteItemConfirmationAlert
                    )
                }
            }
        }
    }
    
    // MARK: - Body
    var body: some View {
        Group {
            if !model.allRecords.isEmpty {
                listOfRecords
            } else {
                emptyHistory
            }
        }
        .navigationTitle("History")
        
        // Optional List Style Modifier (Done b/c sidebar style takes over on iPadOS)
        #if os(iOS)
        .listStyle(.insetGrouped)
        #endif
    
        // Record Editor
        .sheet(
            item: $recordEditSelection,
            onDismiss: { recordEditSelection = nil }
        ) { record in
            NavigationView { EditRecordScreen(record) }
        }
    
        // Delete All Logs Confirmation Dialog
        .confirmationDialog(
            "Delete Logs",
            isPresented: $showDeleteAllConfirmationAlert,
            actions: {
                Button("Cancel", role: .cancel) { }
                
                Button("Delete", role: .destructive) {
                    model.records = []
                    model.pinnedRecords = []
                }
            },
            message: {
                Text("Are you sure you want to delete all logs?")
            }
        )
    
        // Delete a selected (pinned) assessment record
        .confirmationDialog(
            "Are you sure?",
            isPresented: $showDeleteItemConfirmationAlert,
            presenting: recordDeleteSelection,
            actions: { record in
                Button("Delete the assessment", role: .destructive) {
                    model.deleteRecord(record)
                    recordDeleteSelection = nil
                    print("Deleting record", record.id.uuidString)
                }
            },
            message: {_ in 
                Text("This will permanetly delete this assessment record")
            }
        )
    
        .toolbar {
            Menu {
                Section {
                    Toggle("Use Groups", isOn: $useGroups)
                    
                    if useGroups {
                        Picker("Group By", selection: $sortBy) {
                            ForEach(RecordSortTypes.allCases, id: \.self) {
                                Text($0.title).tag($0)
                            }
                        }
                    }
                }
                
                
                // Delete All Logs Button
                Section {
                    Button(role: .destructive) {
                        showDeleteAllConfirmationAlert = true
                    } label: {
                        Label("Delete Logs", systemImage: "trash.fill")
                    }
                }
            } label: {
                Label("More", systemImage: "ellipsis.circle")
            }
        }
    }
}

extension HistoryScreen {
    
    // MARK: - RecordGroup
    struct RecordGroup {
        var title: String?
        var records: [AssessmentRecord]
    }
}

extension HistoryScreen {
    
    // MARK: - SortTypes
    enum RecordSortTypes : String, CaseIterable {
        case kind = "kind"
        case date = "date"
        case pinned = "pinned"
        
        var title : String {
            switch self {
            case .kind:     return "Kind"
            case .date:     return "Date"
            case .pinned:   return "Pinned"
            }
        }
    }
}

struct HistoryScreen_Previews: PreviewProvider {
    static var previews: some View {
        HistoryScreen()
    }
}
