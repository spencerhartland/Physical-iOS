//
//  DataEntryListItemView.swift
//  Vinyls
//
//  Created by Spencer Hartland on 7/9/23.
//

import SwiftUI

struct TextEntryListItemView: View {
    let header: String
    let prompt: String
    let footer: String?
    
    @Binding var input: String
    
    init(header: String, prompt: String, footer: String? = nil, input: Binding<String>) {
        self.header = header
        self.prompt = prompt
        self.footer = footer
        self._input = input
    }
    
    var body: some View {
        Section {
            TextField(prompt, text: $input)
        } header: {
            Text(header)
        } footer: {
            if let footer = footer {
                Text(footer)
            }
        }
    }
}

struct DateEntryListItemView: View {
    private let rightChevronSymbol = "chevron.right"
    
    let header: String
    let prompt: String
    let footer: String?
    
    @Binding var input: Date
    @State private var userHasSelected = false
    @State private var presentPicker = false
    
    init(header: String, prompt: String, footer: String? = nil, input: Binding<Date>) {
        self.header = header
        self.prompt = prompt
        self.footer = footer
        self._input = input
    }
    
    var body: some View {
        Section {
            NavigationLink {
                dateSelection
            } label: {
                Text(userHasSelected ? DateFormatter.localizedString(from: input, dateStyle: .long, timeStyle: .none) : prompt)
                    .foregroundStyle(userHasSelected ? .primary : .tertiary)
            }
        } header: {
            Text(header)
        } footer: {
            if let footer = footer {
                Text(footer)
            }
        }
    }
    
    private var dateSelection: some View {
        VStack {
            DatePicker(header, selection: $input, displayedComponents: [.date])
                .datePickerStyle(.graphical)
            Spacer()
        }
        .padding()
        .navigationTitle(header)
        .onAppear {
            userHasSelected = true
        }
    }
}

struct MediaTypeSelectionListItemView: View {
    private let selectedSymbolName = "checkmark.circle.fill"
    private let notSelectedSymbolName = "circle"
    
    let header: String
    let prompt: String
    let footer: String?
    
    @Binding var input: Media.MediaType
    @State private var userHasSelected = false
    
    init(header: String, prompt: String, footer: String? = nil, input: Binding<Media.MediaType>) {
        self.header = header
        self.prompt = prompt
        self.footer = footer
        self._input = input
    }
    
    var body: some View {
        Section {
            NavigationLink {
                multichoice
            } label: {
                Text("\(userHasSelected ? input.rawValue : prompt)")
                    .foregroundStyle(userHasSelected ? .primary : .tertiary)
            }
        } header: {
            Text(header)
        } footer: {
            if let footer = footer {
                Text(footer)
            }
        }
    }
    
    private var multichoice: some View {
        List(Media.MediaType.allCases) { mediaType in
            Button {
                input = mediaType
            } label: {
                HStack {
                    if input.rawValue == mediaType.rawValue {
                        Image(systemName: selectedSymbolName)
                            .foregroundStyle(.accent)
                    } else {
                        Image(systemName: notSelectedSymbolName)
                            .foregroundStyle(.secondary)
                    }
                    Text(mediaType.rawValue)
                }
            }
        }
        .onAppear {
            userHasSelected = true
        }
    }
}

struct MediaConditionSelectionListItemView: View {
    private let selectedSymbolName = "checkmark.circle.fill"
    private let notSelectedSymbolName = "circle"
    
    let header: String
    let prompt: String
    let footer: String?
    
    @Binding var input: Media.MediaCondition
    @State private var userHasSelected = false
    
    init(header: String, prompt: String, footer: String? = nil, input: Binding<Media.MediaCondition>) {
        self.header = header
        self.prompt = prompt
        self.footer = footer
        self._input = input
    }
    
    var body: some View {
        Section {
            NavigationLink {
                multichoice
            } label: {
                Text("\(userHasSelected ? input.rawValue : prompt)")
                    .foregroundStyle(userHasSelected ? .primary : .tertiary)
            }
        } header: {
            Text(header)
        } footer: {
            if let footer = footer {
                Text(footer)
            }
        }
    }
    
    private var multichoice: some View {
        List(Media.MediaCondition.allCases) { condition in
            Button {
                input = condition
            } label: {
                HStack {
                    if input.rawValue == condition.rawValue {
                        Image(systemName: selectedSymbolName)
                            .foregroundStyle(.accent)
                    } else {
                        Image(systemName: notSelectedSymbolName)
                            .foregroundStyle(.secondary)
                    }
                    Text(condition.rawValue)
                }
            }
        }
        .onAppear {
            userHasSelected = true
        }
    }
}

struct PhotoSelectionView: View {
    private let openPhotosSymbolName = "photo"
    private let openCameraSymbolName = "camera"
    
    var body: some View {
        Button {
            print("tapped")
        } label: {
            ZStack {
                Color(UIColor.secondarySystemBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .aspectRatio(1.0, contentMode: .fit)
                    .padding()
                HStack {
                    Image(systemName: openPhotosSymbolName)
                    Image(systemName: openCameraSymbolName)
                }
                .font(.system(size: 32))
                .foregroundStyle(.tertiary)
            }
        }
    }
}
