//
//  SocialView.swift
//  Physical
//
//  Created by Spencer Hartland on 10/13/23.
//

import SwiftUI

struct SocialView: View {
    private let searchSymbolName = "magnifyingglass"
    
    @Binding var userID: String
    
    init(for user: Binding<String>) {
        self._userID = user
    }
    
    var body: some View {
        if userID.isEmpty {
            NoAccountView()
        } else {
            NavigationStack {
                List {
                    SocialSimplePostView()
                    SocialListPostView()
                }
                .listStyle(.plain)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        searchButton
                    }
                }
            }
        }
    }
    
    // MARK: - UI Elements
    
    private var searchButton: some View {
        Button {
            print("Search")
        } label: {
            Image(systemName: searchSymbolName)
        }
    }
}

#Preview {
    @State var screenSize: CGSize = {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        
        return window.screen.bounds.size
    }()
    
    return SocialView(for: .constant("12345678"))
        .environment(\.screenSize, screenSize)
}
