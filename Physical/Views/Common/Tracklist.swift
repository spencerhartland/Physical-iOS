//
//  Tracklist.swift
//  Physical
//
//  Created by Spencer Hartland on 6/20/25.
//

import SwiftUI

struct Tracklist<Content: View>: View {
    @State private var isEditable: Bool
    @State private var newTrackTitle: String = ""
    
    @FocusState private var focusInNewTrackField: Bool
    
    @Binding var tracklist: [String]
    @Binding var editMode: EditMode
    private var header: () -> Content
    
    init(
        _ tracklist: Binding<[String]>,
        editMode: Binding<EditMode> = .constant(.inactive),
        isEditable: Bool = false,
        @ViewBuilder _ header: @escaping () -> Content = { EmptyView() }
    ) {
        self._tracklist = tracklist
        self._editMode = editMode
        self.isEditable = isEditable
        self.header = header
    }
    
    var body: some View {
        Section {
            if isEditable {
                mutableList
            } else {
                immutableList
            }
        } header: {
            header()
        } footer: {
            if isEditable { tracklistEditButton }
        }
    }
    
    private var immutableList: some View {
        Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 16) {
            ForEach(Array(tracklist.enumerated()), id: \.offset) { trackIndex, trackTitle in
                GridRow {
                    Text("\(trackIndex + 1)")
                        .foregroundStyle(.secondary)
                        .gridColumnAlignment(.trailing)
                    HStack {
                        Text(trackTitle)
                            .foregroundStyle(.primary)
                            .gridColumnAlignment(.leading)
                        Spacer()
                    }
                }
                
                if let lastTrack = tracklist.last,
                   trackTitle != lastTrack {
                    Divider()
                }
            }
        }
    }
    
    private var mutableList: some View {
        ForEach(Array(tracklist.enumerated()), id: \.offset) { trackIndex, trackTitle in
            TextField(
                "Track \(trackIndex + 1) title",
                text: $tracklist[trackIndex]
            )
            
            if let lastTrack = tracklist.last,
               trackTitle == lastTrack {
                TextField("Track \(trackIndex + 2) title", text: $newTrackTitle)
                    .focused($focusInNewTrackField)
            }
        }
        .onDelete(perform: removeTrack)
        .onMove(perform: moveTrack)
        .onChange(of: focusInNewTrackField) { _, focused in
            if !focused && !newTrackTitle.isEmpty {
                tracklist.append(newTrackTitle)
                newTrackTitle = ""
            }
        }
    }
    
    // MARK: - Components
    private var tracklistEditButton: some View {
        HStack {
            Spacer()
            Button {
                editMode = editMode == .active ? .inactive : .active
            } label: {
                HStack {
                    Image(systemName: editMode == .active ? "pencil.slash" : "pencil")
                    if editMode == .active {
                        Text("Cancel")
                    } else {
                        Text("Edit tracklist")
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .buttonStyle(.bordered)
            .disabled($tracklist.isEmpty)
            Spacer()
        }
        .padding(.top)
    }
    
    // MARK: - Track list editing logic
    private func removeTrack(at offsets: IndexSet) {
        tracklist.remove(atOffsets: offsets)
        endEditingIfTracklistEmpty()
    }
    
    private func moveTrack(source: IndexSet, destination: Int) {
        tracklist.move(fromOffsets: source, toOffset: destination)
    }
    
    private func endEditingIfTracklistEmpty() {
        if tracklist.isEmpty && editMode == .active {
            editMode = .inactive
        }
    }
}
