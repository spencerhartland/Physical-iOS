//
//  OwnershipPicker.swift
//  prototyping
//
//  Created by Spencer Hartland on 8/6/23.
//

import SwiftUI

struct OwnershipPicker: View {
    private let pickerPrompt = "Own it or Want it?"
    private let ownedSymbol = "star.circle.fill"
    private let wantedSymbol = "star.circle"
    private enum OwnershipStatus: String, CaseIterable {
        case owned = "I own this"
        case wanted = "I want this"
    }
    @State private var ownership: OwnershipStatus = .owned
    
    @Binding var selection: Bool
    
    var body: some View {
        Picker(selection: $ownership) {
            ForEach(OwnershipStatus.allCases, id: \.self) { choice in
                Text(choice.rawValue)
            }
        } label: {
            ListItemLabel(
                color: .yellow,
                symbolName: (ownership == .owned) ? ownedSymbol : wantedSymbol,
                labelText: pickerPrompt
            )
        }
        .onChange(of: ownership) { _, value in
            selection = (value == .owned) ? true : false
        }
    }
}

#Preview {
    @Previewable @State var selection = true
    
    return List {
        Section {
            OwnershipPicker(selection: $selection)
        }
    }
}
