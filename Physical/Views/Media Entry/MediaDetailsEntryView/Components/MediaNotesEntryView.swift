//
//  MediaNotesEntryView.swift
//  Physical
//
//  Created by Spencer Hartland on 7/20/23.
//

import SwiftUI

struct MediaNotesEntryView: View {
    private let navTitle = "Notes"
    private let notesHeaderText = "Add notes"
    private let clearButtonSymbol = "trash"
    
    @Binding var notes: String
    
    var body: some View {
        List {
            Section {
                TextEditor(text: $notes)
            } header: {
                Text(notesHeaderText)
            }
        }
        .navigationTitle(navTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    self.notes = ""
                } label: {
                    Image(systemName: clearButtonSymbol)
                }
            }
        }
    }
}
