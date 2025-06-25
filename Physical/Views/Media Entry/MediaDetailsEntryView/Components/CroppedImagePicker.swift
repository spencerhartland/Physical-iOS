//
//  CroppedImagePicker.swift
//  Physical
//
//  Created by Spencer Hartland on 7/24/23.
//

import SwiftUI
import PhotosUI

// MARK: View extension
extension View {
    @ViewBuilder
    func croppedImagePicker(
        pickerIsPresented: Binding<Bool>,
        cameraIsPresented: Binding<Bool>,
        croppedImage: Binding<UIImage?>) -> some View {
            
        CroppedImagePicker(
            pickerIsPresented: pickerIsPresented,
            cameraIsPresented: cameraIsPresented,
            croppedImage: croppedImage) {
            self
        }
    }
}

fileprivate struct CroppedImagePicker<Content: View>: View {
    var content: Content
    @Binding var pickerIsPresented: Bool
    @Binding var cameraIsPresented: Bool
    @Binding var croppedImage: UIImage?
    
    @State private var cropViewIsPresented: Bool =  false
    @State private var photosItem: PhotosPickerItem?
    @State private var rawImage: UIImage?
    
    init(
        pickerIsPresented: Binding<Bool>,
        cameraIsPresented: Binding<Bool>,
        croppedImage: Binding<UIImage?>,
        @ViewBuilder content: @escaping () -> Content) {
            self._pickerIsPresented = pickerIsPresented
            self._cameraIsPresented = cameraIsPresented
            self._croppedImage = croppedImage
            self.content = content()
    }
    
    var body: some View {
        content
            .photosPicker(isPresented: $pickerIsPresented, selection: $photosItem, matching: .images)
            .fullScreenCover(isPresented: $cameraIsPresented) {
                ImagePicker(image: $rawImage)
                    .ignoresSafeArea()
            }
            .onChange(of: photosItem) { _, item in
                if let item {
                    loadImageData(from: item, to: $rawImage)
                }
            }
            .onChange(of: rawImage) { _, _ in
                if rawImage != nil {
                    self.cropViewIsPresented.toggle()
                }
            }
            .fullScreenCover(isPresented: $cropViewIsPresented) {
                self.photosItem = nil
                self.rawImage = nil
            } content: {
                CropView(raw: rawImage, cropped: $croppedImage)
            }
    }
    
    private func loadImageData(from photosItem: PhotosPickerItem, to binding: Binding<UIImage?>) {
        Task {
            if let imageData = try? await photosItem.loadTransferable(type: Data.self),
               let image = UIImage(data: imageData) {
                await MainActor.run {
                    binding.wrappedValue = image
                }
            }
        }
    }
}

// TODO: Make this look better
fileprivate struct CropView: View {
    private let coordinateSpace = "CropView"
    private let navTitle = "Crop Image"
    private let cancelButtonText = "Cancel"
    private let doneButtonText = "Done"
    private let crop = CGSize(width: 300, height: 300)
    private let handlesOffset: CGFloat = 3.0
    
    var image: UIImage?
    @Binding var croppedImage: UIImage?
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 0.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @GestureState private var isInteracting: Bool = false
    
    init(raw: UIImage?, cropped: Binding<UIImage?>) {
        self.image = raw
        self._croppedImage = cropped
    }
    
    var body: some View {
        NavigationStack {
            imageView()
                .navigationTitle(navTitle)
                .navigationBarTitleDisplayMode(.inline)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(cancelButtonText) {
                            dismiss()
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(doneButtonText) {
                            convertImage()
                            dismiss()
                        }
                    }
                }
        }
        .preferredColorScheme(.dark)
        .background {
            Color.black
                .ignoresSafeArea()
        }
    }
    
    private func imageView(showHandles: Bool = true) -> some View {
        ZStack {
            if let image {
                croppedSection
                
                GeometryReader {
                    let size = $0.size
                    
                    Image(uiImage: image)
                        .resizable()
                        .overlay {
                            GeometryReader { geo in
                                let rect = geo.frame(in: .named(coordinateSpace))
                                Color.clear
                                    .onChange(of: isInteracting) { _, newValue in
                                        if !newValue {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                if rect.minX > 0 {
                                                    offset.width = offset.width - rect.minX
                                                }
                                                if rect.minY > 0 {
                                                    offset.height = offset.height - rect.minY
                                                }
                                                if rect.maxX < size.width {
                                                    offset.width = rect.minX - offset.width
                                                }
                                                if rect.maxY < size.height {
                                                    offset.height = rect.minY - offset.height
                                                }
                                            }
                                            lastOffset = offset
                                        }
                                    }
                            }
                        }
                        .scaledToFill()
                        .frame(width: size.width, height: size.height)
                        .scaleEffect(scale)
                        .offset(offset)
                        .clipped()
                }
                .coordinateSpace(name: coordinateSpace)
                .gesture(
                    DragGesture()
                        .updating($isInteracting) { _, out, _ in
                            out = true
                        }
                        .onChanged { value in
                            let translation = value.translation
                            offset = CGSize(width: translation.width + lastOffset.width, height: translation.height + lastOffset.height)
                        }
                )
                .gesture(
                    MagnificationGesture()
                        .updating($isInteracting) { _, out, _ in
                            out = true
                        }
                        .onChanged { value in
                            let updatedScale = value + lastScale
                            scale = updatedScale < 1 ? 1 : updatedScale
                        }
                        .onEnded { _ in
                            withAnimation(.easeInOut(duration: 0.2)) {
                                if scale < 1 {
                                    scale = 1
                                    lastScale = 0
                                } else {
                                    lastScale = scale - 1
                                }
                            }
                        }
                )
                .frame(width: crop.width, height: crop.height)
                .padding(showHandles ? handlesOffset : 0)
                .overlay {
                    if showHandles {
                        CropHandles()
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
    
    private var croppedSection: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: crop.width, height: crop.height)
                    .scaleEffect(scale)
                    .offset(offset)
                
                Rectangle()
                    .foregroundStyle(.ultraThinMaterial)
                    .ignoresSafeArea()
            }
        }
    }
    
    @MainActor
    private func convertImage() {
        let renderer = ImageRenderer(content: imageView(showHandles: false))
        renderer.proposedSize = .init(crop)
        self.croppedImage = renderer.uiImage
    }
}

fileprivate struct CropHandles: View {
    var body: some View {
        ZStack {
            Rectangle()
                .stroke(lineWidth: 1.0)
                .padding(3)
            VStack(spacing: 0) {
                horizontalHandles
                HStack(spacing: 0) {
                    verticalHandles
                    Spacer()
                    verticalHandles
                }
                horizontalHandles
            }
        }
        .foregroundStyle(.primary)
    }
    
    private var horizontalHandles: some View {
        HStack {
            Rectangle()
                .frame(width: 32, height: 3)
            Spacer()
            Rectangle()
                .frame(width: 32, height: 2)
            Spacer()
            Rectangle()
                .frame(width: 32, height: 3)
        }
    }
    
    private var verticalHandles: some View {
        VStack {
            Rectangle()
                .frame(width: 3, height: 29)
            Spacer()
            Rectangle()
                .frame(width: 2, height: 32)
            Spacer()
            Rectangle()
                .frame(width: 3, height: 29)
        }
    }
}
