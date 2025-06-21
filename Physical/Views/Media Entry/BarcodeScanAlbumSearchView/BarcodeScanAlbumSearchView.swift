//
//  BarcodeScanAlbumSearchView.swift
//  Physical
//
//  Created by Spencer Hartland on 12/15/23.
//

import SwiftUI
import MusicKit
import AVFoundation

struct BarcodeScanAlbumSearchView: View {
    private let flashlightOnSymbolName = "flashlight.on.fill"
    private let flashlightOffSymbolName = "flashlight.off.fill"
    private let tooltipText = "Scan the barcode"
    private let tooltipSymbolName = "barcode.viewfinder"
    private let footerText = "Barcode scanning works on the one-dimensional barcodes of most vinyl records, CDs, and cassettes. Not all UPCs yield results from Apple Music."
    
    @State private var detectedBarcode: String = ""
    @State private var detectedAlbum: Album?
    @State private var searchReturnedNoResults: Bool = false
    @State private var flashlightActive: Bool = false
    @State private var doneScanning: Bool = false
    @State private var newMedia = Media()
    @State private var editingMediaDetails: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                BarcodeScanningView($detectedBarcode)
                    .clipShape(Rectangle())
                    .ignoresSafeArea(edges: .top)
                    .overlay {
                        VStack {
                            Spacer()
                            barcodeScanningTooltip
                        }
                    }
                VStack(alignment: .center, spacing: 16) {
                    Button {
                        editingMediaDetails = true
                    } label: {
                        BarcodeSearchResultView(for: detectedAlbum, completionFlag: $searchReturnedNoResults)
                    }
                    Text(footerText)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
        }
        .navigationDestination(isPresented: $editingMediaDetails) {
            @Bindable var newMedia = newMedia
            MediaDetailsEntryView(newMedia: $newMedia, isPresented: $editingMediaDetails)
        }
        .onChange(of: detectedBarcode) { oldValue, newValue in
            if newValue != oldValue {
                handleDetectedBarcode(newValue)
            }
        }
        .onChange(of: flashlightActive) { _, newValue in
            setTorchState(on: newValue)
        }
        .onChange(of: editingMediaDetails) {
            if !editingMediaDetails {
                newMedia = Media()
                // TODO: Show some confirmation that media was added.
            }
        }
        .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
        .toolbarVisibility(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if #available(iOS 26.0, *) {
                    flashlightToggle
                        .tint(flashlightActive ? .darkGreen : nil)
                } else {
                    flashlightToggle
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                        .tint(Color(UIColor.systemBackground))
                        .foregroundStyle(flashlightActive ? Color.darkGreen : .primary)
                }
            }
        }
    }
    
    // MARK: - UI Elements
    
    // Tooltip centered below the top bar calling users to action.
    private var barcodeScanningTooltip: some View {
        Label(tooltipText, systemImage: tooltipSymbolName)
            .font(.caption)
            .padding(4)
            .background {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .foregroundStyle(.thinMaterial)
            }
            .padding(16)
    }
    
    // Button for toggling the flashlight on and off
    private var flashlightToggle: some View {
        Button {
            withAnimation(.bouncy) {
                flashlightActive.toggle()
            }
        } label: {
            if flashlightActive {
                Label("Turn flashlight off", systemImage: flashlightOnSymbolName)
                    .labelStyle(.iconOnly)
            } else {
                Label("Turn flashlight on", systemImage: flashlightOffSymbolName)
                    .labelStyle(.iconOnly)
            }
        }
    }
    
    // MARK: - Barcode detection handling
    
    private func handleDetectedBarcode(_ detectedBarcode: String) {
        if !detectedBarcode.isEmpty {
            Task {
                do {
                    let albumsRequest = MusicCatalogResourceRequest<Album>(matching: \.upc, equalTo: detectedBarcode)
                    let albumsResponse = try await albumsRequest.response()
                    if let firstAlbum = albumsResponse.items.first {
                        self.handleDetectedAlbum(firstAlbum)
                    } else {
                        self.handleNoResults()
                    }
                } catch {
                    print("Encountered error while trying to find albums with upc = \"\(detectedBarcode)\".")
                }
            }
        }
    }
    
    @MainActor
    private func handleDetectedAlbum(_ detectedAlbum: Album) {
        newMedia.updateWithInfo(from: detectedAlbum)
        self.searchReturnedNoResults = false
        self.detectedAlbum = detectedAlbum
    }
    
    @MainActor
    private func handleNoResults() {
        newMedia.resetInfo()
        self.searchReturnedNoResults = true
        self.detectedAlbum = nil
    }
    
    // MARK: - Torch control
    private func setTorchState(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                device.torchMode = on ? .on : .off
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used.")
            }
        } else {
            print("Torch is not available.")
        }
    }
}
