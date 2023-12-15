//
//  BarcodeScanningViewController.swift
//  Physical
//
//  Created by Spencer Hartland on 12/14/23.
//

import AVFoundation
import SwiftUI
import UIKit

/// `BarcodeScanningViewController` is a view controller for recognizing regular one-dimensional barcodes.
/// This view controller accomplishes this using `AVCaptureSession` and `AVCaptureVideoPreviewLayer`.
class BarcodeScanningViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    // MARK: - Object lifecycle
    
    init(_ detectedBarcode: Binding<String>) {
        self._detectedBarcode = detectedBarcode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    @State private var barcodeShapeLayer: CAShapeLayer = CAShapeLayer()
    
    /// A barcode string that the barcode scanning view detects.
    @Binding var detectedBarcode: String
    
    /// A capture session for enabling the camera.
    private var captureSession: AVCaptureSession?
    
    /// The capture session’s preview content.
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        // Set up the capture device.
        let captureSession = AVCaptureSession()
        let metadataOutput = AVCaptureMetadataOutput()
        if
            let videoCaptureDevice = AVCaptureDevice.default(for: .video),
            let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
            captureSession.canAddInput(videoInput),
            captureSession.canAddOutput(metadataOutput) {
            
            // Configure the capture session.
            self.captureSession = captureSession
            captureSession.addInput(videoInput)
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13]
            
            // Configure the preview layer.
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            self.previewLayer = previewLayer
            
            previewLayer.frame = view.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
            
            // Start the capture session from a background thread to avoid UI responsiveness issues.
            DispatchQueue.global(qos: .background).async {
                captureSession.startRunning()
            }
        } else {
            let scanningUnsupportedAlertController = UIAlertController(
                title: "Scanning not supported",
                message: "Your device does not support scanning a code from an item. Please use a device with a camera.",
                preferredStyle: .alert
            )
            let okAlertAction = UIAlertAction(title: "OK", style: .default)
            scanningUnsupportedAlertController.addAction(okAlertAction)
            present(scanningUnsupportedAlertController, animated: true)
        }
    }
    
    /// Resumes the current capture session, if any, when the view appears.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let captureSession = self.captureSession, !captureSession.isRunning {
            DispatchQueue.global(qos: .background).async {
                captureSession.startRunning()
            }
        }
    }
    
    /// Suspends the current capture session, if any, when the view disappears.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let captureSession = self.captureSession, captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    /// Hides the status bar when a capture is running.
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    /// Forces this view into portrait orientation.
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // MARK: - Capture metadata output objects delegate
    
    /// Captures a barcode string, if there is one in the current capture session.
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check that a barcode is available.
        if
            let previewLayer = self.previewLayer,
            let metadataObject = metadataObjects.first,
            let readableObject = previewLayer.transformedMetadataObject(for: metadataObject) as? AVMetadataMachineReadableCodeObject,
            let detectedBarcode = readableObject.stringValue {
            
            // A new barcode has been detected.
            if detectedBarcode != self.detectedBarcode {
                // Provide haptic feedback when the barcode scanning view controller detects a barcode.
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                
                // Highlight the detected barcode
                var barcodeCorners = readableObject.corners
                if !barcodeCorners.isEmpty {
                    let barcodePath = UIBezierPath()
                    let firstCorner = barcodeCorners.removeFirst()
                    barcodePath.move(to: firstCorner)
                    for corner in barcodeCorners {
                        barcodePath.addLine(to: corner)
                    }
                    barcodePath.close()
                    
                    highlightBarcode(with: barcodePath, to: previewLayer)
                }
                print("Barcode scanned: \(detectedBarcode)")
                
                // Remember the recognized barcode string.
                self.detectedBarcode = detectedBarcode
            }
            
        } else {
            barcodeShapeLayer.removeFromSuperlayer()
            self.detectedBarcode = ""
        }
    }
    
    // MARK: - Highlight detected barcode
    
    /// Highlights the recognized barcode.
    private func highlightBarcode(with barcodePath: UIBezierPath, to parentLayer: CALayer) {
        // Reset shape layer
        barcodeShapeLayer.removeFromSuperlayer()
        
        // Style the line
        barcodeShapeLayer.path = barcodePath.cgPath
        barcodeShapeLayer.strokeColor = UIColor.white.cgColor
        barcodeShapeLayer.lineWidth = 1.0
        
        // Add bounds and position
        let barcodeBounds = barcodePath.bounds
        barcodeShapeLayer.bounds = barcodeBounds
        barcodeShapeLayer.position = CGPoint(x: barcodeBounds.midX, y: barcodeBounds.midY)
        barcodeShapeLayer.masksToBounds = true
        
        // Add shape layer as sublayer of parent layer
        parentLayer.addSublayer(barcodeShapeLayer)
        
        // Add animation
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.autoreverses = true
        opacityAnimation.duration = 0.3
        opacityAnimation.repeatCount = 5
        opacityAnimation.toValue = 0.0
        barcodeShapeLayer.add(opacityAnimation, forKey: opacityAnimation.keyPath)
    }
}
