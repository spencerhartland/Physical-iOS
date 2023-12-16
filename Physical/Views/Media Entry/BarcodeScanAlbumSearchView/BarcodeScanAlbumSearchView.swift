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
    private let captionAwaitingScanText = "Scan the barcode on a vinyl record, CD, or cassette to search Apple Music."
    private let captionSearchingText = "Searching..."
    private let captionNoResultsFoundText = "No results found on Apple Music matching the scanned UPC."
    
    @Binding var isPresented: Bool
    
    @Bindable private var newMedia: Media = Media()
    
    @State private var detectedBarcode: String = ""
    @State private var detectedAlbum: Album?
    @State private var flashlightActive: Bool = false
    @State private var doneScanning: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                BarcodeScanningView($detectedBarcode)
                    .ignoresSafeArea()
                VStack {
                    barcodeScanningTooltip
                    Spacer()
                    if let detectedAlbum {
                        Button {
                            doneScanning = true
                        } label: {
                            BarcodeSearchResultView(for: detectedAlbum)
                        }
                        .transition(.move(edge: .bottom))
                    }
                }
            }
            .navigationDestination(isPresented: $doneScanning) {
                MediaDetailsEntryView(newMedia: $newMedia, isPresented: $isPresented)
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar(.hidden, for: .tabBar)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    flashlightToggle
                }
            }
            .variableBlurNavigationBackground()
        }
        .onChange(of: detectedBarcode) { oldValue, newValue in
            if newValue != oldValue {
                handleDetectedBarcode(newValue)
            }
        }
        .onChange(of: flashlightActive) { _, newValue in
            setTorchState(on: newValue)
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
            Image(systemName: flashlightActive ? flashlightOnSymbolName : flashlightOffSymbolName)
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
                        await self.handleDetectedAlbum(firstAlbum)
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
        withAnimation(.bouncy) {
            self.detectedAlbum = detectedAlbum
        }
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
