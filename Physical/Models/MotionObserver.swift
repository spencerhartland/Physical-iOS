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
    private let yOffset = -0.1
    private let yMultiplier = 0.1
    private let zMultiplier = 0.01
    private let frequency = 1.0 / 50.0 // 50 times per second
    private var motion = CMMotionManager()
    var roll: Double = 0.0
    var pitch: Double = 0.0
    var yaw: Double = 0.0
    
    private var counter: Int = 0
    
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
            
            // Radians
            let rollRads = data.attitude.roll * self.xMultiplier
            let pitchRads = (data.attitude.pitch * self.yMultiplier) + self.yOffset
            let yawRads = data.attitude.yaw * self.zMultiplier
            
            // Degreees
            let rollDegs = self.degrees(from: rollRads)
            let pitchDegs = self.degrees(from: pitchRads)
            let yawDegs = self.degrees(from: yawRads)
            
            withAnimation {
                self.roll = self.limit(rollDegs, min: -2.0, max: 2.0)
                self.pitch = self.limit(pitchDegs, min: -1.0, max: 1.0)
                self.yaw = self.limit(yawDegs, min: -0.33, max: 0.33)
            }
        }
    }
    
    private func limit(_ degrees: Double, min: Double, max: Double) -> Double {
        if degrees < min {
            return min
        } else if degrees > max {
            return max
        } else {
            return degrees
        }
    }
    
    private func degrees(from radians: Double) -> Double {
        return radians * 180 / .pi
    }
}
