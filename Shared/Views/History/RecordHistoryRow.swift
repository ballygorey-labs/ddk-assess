//
//  RecordHistoryRow.swift
//  RecordHistoryRow
//
//  Created by Collin Dunphy on 7/19/21.
//

import SwiftUI

struct RecordHistoryRow: View {

    @EnvironmentObject var model: DDKModel

    @Environment(\.dismiss) var dismiss

    @State private var recordGetInfoPopover: Bool = false
    @State private var deleteConfirmationIsPresented: Bool = false

    var record: AssessmentRecord
    @Binding var recordEditSelection: AssessmentRecord?
    @Binding var recordDeleteSelection: AssessmentRecord?
    @Binding var showDeleteItemConfirmationAlert: Bool

    // MARK: - Row
    var row: some View {
        HStack {
            Label(record.type.title, systemImage: record.type.icon)
                .font(.title3)
                .foregroundColor(record.type.color)
                .labelStyle(.iconOnly)

            VStack(alignment: .leading) {

                Text("\(record.taps) \(record.taps == 1 ? "tap" : "taps")")

                HStack {
                    Text(record.date, style: .time)
                        + Text(" — ")
                        + Text("\(record.durationDescription)")
                    //                    + Text(record.duration.formatted())
                }
                .foregroundColor(.secondary)
                .font(.caption)
                
            }

            Spacer()

            if model.recordIsPinned(record.id) {
                Label("Pinned", systemImage: "pin.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .labelStyle(.iconOnly)
                    .foregroundColor(.secondary)
                    .imageScale(.small)
            }
        }
    }

    // MARK: - Body
    var body: some View {
        row
            .contextMenu {
                Button {
                    recordGetInfoPopover = true
                } label: {
                    Label("Get Info", systemImage: "info.circle")
                }

                editButton

                pinButton

                Section {
                    deleteButton
                }
            }

            // Information on a Record
            .popover(isPresented: $recordGetInfoPopover, arrowEdge: .trailing) {
                RecordGeneralInfo(record)
            }

            // Swipe Action Shortcuts
            .swipeActions(edge: .leading) {
                pinButton
                    .tint(.accentColor)
            }

            .swipeActions {
                editButton
                    .tint(.yellow)

                deleteButton
            }
    }

    // Delete Record Button
    var deleteButton: some View {
        Button(role: .destructive) {
            if model.recordIsPinned(record.id) {
                showDeleteItemConfirmationAlert = true
                recordDeleteSelection = record
            } else {
                model.deleteRecord(record)
            }
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }

    // Edit Record Button
    var editButton: some View {
        Button {
            recordEditSelection = record
        } label: {
            Label("Edit", systemImage: "slider.horizontal.3")
                .font(.largeTitle)
        }
    }

    // Pin Record Button
    var pinButton: some View {
        Button {
            model.pinRecord(record)
        } label: {
            if model.recordIsPinned(record.id) {
                Label("Unpin", systemImage: "pin.slash")
            } else {
                Label("Pin", systemImage: "pin")
            }
        }
    }
}

struct HistoryRecordButton_Previews: PreviewProvider {
    static var previews: some View {
        RecordHistoryRow(
            record: AssessmentRecord(
                date: Date(),
                taps: 7,
                type: .timed,
                duration: 15
            ),
            recordEditSelection: .constant(nil),
            recordDeleteSelection: .constant(nil),
            showDeleteItemConfirmationAlert: .constant(false)
        )
    }
}
