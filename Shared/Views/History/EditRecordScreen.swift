//
//  EditRecordScreen.swift
//  EditRecordScreen
//
//  Created by Collin Dunphy on 7/19/21.
//

import SwiftUI

struct EditRecordScreen: View {
    
    @EnvironmentObject var model : DDKModel
    @Environment(\.dismiss) var dismiss
    
    @State private var draftRecord : AssessmentRecord = AssessmentRecord(date: .now, taps: 0, type: .timed, duration: 0)
    @State private var imported : Bool = false
    
    @State private var deleteConfirmationIsPresented : Bool = false

    var record: AssessmentRecord
    
    init(_ record: AssessmentRecord) {
        self.record = record
    }
    
    var body: some View {
        Form {
            Section {
                
                Picker("Assessment Type", selection: $draftRecord.type) {
                    ForEach(AssessmentType.allCases) {
                        Text($0.title)
                            .tag($0)
                    }
                }
                
                DatePicker(
                    "Date & Time",
                    selection: $draftRecord.date,
                    displayedComponents: [.date, .hourAndMinute]
                )
                
                DisclosureGroup("Duration: \(draftRecord.durationDescription)") {
                    durationEditor
                }
            }
            
            Section {
                Stepper(
                    "Taps: \(draftRecord.taps)",
                    value: $draftRecord.taps,
                    in: 0...(draftRecord.type != .count ? .max : draftRecord.goal ?? Defaults.Count.goal)
                )
                
                if draftRecord.type == .count {
                    Stepper(
                        "Goal: \(draftRecord.goal ?? Defaults.Count.goal)",
                        value: $draftRecord.goal ?? Defaults.Count.goal,
                        in: draftRecord.taps...(.max)
                    )
                }
            }
            
            Section {
                Button(role: .destructive) {
                    deleteConfirmationIsPresented = true
                } label: {
                    Label("Delete Assessment", systemImage: "trash")
                        .foregroundColor(.red)
                }
                .confirmationDialog("Are you sure?", isPresented: $deleteConfirmationIsPresented) {
                    Button(role: .destructive) {
                        model.deleteRecord(record)
                        dismiss()
                        
                    } label: {
                        Text("Delete the assessment")
                    }
                    
                }
            }
            
        }
        .navigationTitle("Edit Record")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            
            // Cancel Button
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Label("Cancel", systemImage: "gobackward")
                        .labelStyle(.titleOnly)
                }
            }
            
            // Save Button
            ToolbarItem(placement: .automatic) {
                Button {
                    model.updateRecord(draftRecord)
                    dismiss()
                } label: {
                    Label("Save", systemImage: "checkmark.circle")
                        .labelStyle(.titleOnly)
                }
            }
        }
        .onAppear {
            print("On Appear")
            if !imported {
                draftRecord = record
                imported = true
                print("Imported: \(record)")
            }
        }
        .onDisappear {
            print("On Disappear")
        }
    }
    
    @ViewBuilder
    var durationEditor : some View {
        Stepper(
            "Minutes",
            onIncrement: {
               
                draftRecord.duration += 60
                
                if draftRecord.duration >= 3600 {
                    draftRecord.duration = 3599.9
                }
            }, onDecrement: {
                
                draftRecord.duration -= 60
                
                if draftRecord.duration < 0 {
                    draftRecord.duration = 0
                }
            }
        )
        
        Stepper(
            "Seconds",
            onIncrement: {
                draftRecord.duration += 1
                
                if draftRecord.duration >= 3600 {
                    draftRecord.duration = 3599.9
                }
            }, onDecrement: {
                
                draftRecord.duration -= 1
                
                if draftRecord.duration < 0 {
                    draftRecord.duration = 0
                }
                
            }
        )
        
        Stepper(
            "Deciseconds",
            onIncrement: {
                draftRecord.duration += 0.1
                
                if draftRecord.duration >= 3600 {
                    draftRecord.duration = 3599.9
                }
            }, onDecrement: {
                
                draftRecord.duration -= 0.1
                
                if draftRecord.duration < 0 {
                    draftRecord.duration = 0
                }
                
            }
        )
    }
}

struct EditRecordScreen_Previews: PreviewProvider {
    static var previews: some View {
        EditRecordScreen(AssessmentRecord(date: Date(), taps: 7, type: .timed, duration: 15))
            .previewLayout(.sizeThatFits)
    }
}
