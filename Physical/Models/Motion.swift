//
//  Motion.swift
//  Physical
//
//  Created by Spencer Hartland on 7/20/23.
//

import CoreMotion
import SwiftData
import SwiftUI

@Observable
final class Motion: ObservableObject {
    static var main = Motion()
    
    private var roll: Double = 0.0
    private var pitch: Double = 0.0
    private var yaw: Double = 0.0
    
    private var manager = CMMotionManager()
    private let xMultiplier = 0.25
    private let yOffset = -0.25
    private let yMultiplier = 0.25
    private let zMultiplier = 0.025
    /// The interval between device motion updates, in seconds.
    private let updateInterval = 0.05 // 50ms
    
    init() {
        manager.deviceMotionUpdateInterval = updateInterval
        manager.startDeviceMotionUpdates(to: .main) { data, error in
            if let error = error {
                print("Error occurred while starting device motion updates: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("Error getting motion data.")
                return
            }
            
            withAnimation {
                self.roll = data.attitude.roll
                self.pitch = data.attitude.pitch
                self.yaw = data.attitude.yaw
            }
        }
    }
    
    public func roll(limited: Bool = false) -> Double {
        if !limited {
            return roll
        }
        
        let result = degrees(from: roll * xMultiplier)
        return limit(result, min: -2.0, max: 2.0)
    }
    
    public func pitch(limited: Bool = false) -> Double {
        if !limited {
            return pitch
        }
        
        let result = degrees(from: (pitch * yMultiplier) + yOffset)
        return limit(result, min: -1.0, max: 1.0)
    }
    
    public func yaw(limited: Bool = false) -> Double {
        if !limited {
            return yaw
        }
        
        let result = degrees(from: yaw * zMultiplier)
        return limit(result, min: -0.33, max: 0.33)
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
