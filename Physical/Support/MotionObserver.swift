//
//  MotionObserver.swift
//  Physical
//
//  Created by Spencer Hartland on 7/20/23.
//

import CoreMotion
import SwiftData
import SwiftUI

@Observable
final class MotionObserver {
    private let xMultiplier = 0.1
    private let yMultiplier = 0.05
    private let zMultiplier = 0.01
    private let frequency = 1.0 / 50.0 // 50 times per second
    private var motion = CMMotionManager()
    var roll: Double = 0.0
    var pitch: Double = 0.0
    var yaw: Double = 0.0
    
    func startUpdates() {
        motion.startDeviceMotionUpdates(to: .main) { data, error in
            if let error = error {
                print("Error occurred while starting device motion updates: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("Error getting motion data.")
                return
            }
            
            withAnimation {
                self.roll = self.degrees(from: data.attitude.roll * self.xMultiplier)
                //self.pitch = self.degrees(from: data.attitude.pitch * self.yMultiplier)
                self.yaw = self.degrees(from: data.attitude.yaw * self.zMultiplier)
            }
        }
    }
    
    private func degrees(from radians: Double) -> Double {
        return radians * 180 / .pi
    }
}
