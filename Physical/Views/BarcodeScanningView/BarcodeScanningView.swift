//
//  BarcodeScanningView.swift
//  Physical
//
//  Created by Spencer Hartland on 12/14/23.
//

import SwiftUI

struct BarcodeScanningView: UIViewControllerRepresentable {
    // MARK: - Object lifecycle
    
    init(_ detectedBarcode: Binding<String>) {
        self._detectedBarcode = detectedBarcode
    }
    
    // MARK: - Properties
    
    @Binding var detectedBarcode: String
    
    // MARK: - View controller representable
    
    func makeUIViewController(context: Context) -> UIViewController {
        return BarcodeScanningViewController($detectedBarcode)
    }
    
    func updateUIViewController(_ viewController: UIViewController, context: Context) {
        // The underlying view controller doesn’t need to be updated in any way.
    }
}

#Preview {
    @State var detectedBarcode: String = ""
    
    return BarcodeScanningView($detectedBarcode)
}
