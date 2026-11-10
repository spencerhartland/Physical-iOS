//
//  DominantColorsCalculator.swift
//  Physical
//
//  Created by Spencer Hartland on 10/30/26.
//

import Accelerate
import CoreGraphics

nonisolated final class DominantColorsCalculator {
    enum DominantColorsCalculatorError: Error {
        case unsupportedImageFormat
        case insufficientOpaquePixels
    }
    
    struct Centroid: Sendable {
        var red: Float
        var green: Float
        var blue: Float
        var pixelCount: Int = 0
    }
    
    private static let k: Int = 5
    private static let maxIterations: Int = 64
    private static let dimension: Int = 256
    private static let tolerance: Int = 10
    private static let alphaThreshold: Float = 0.5
    
    private let pixelCount: Int
    
    private let redStorage: UnsafeMutableBufferPointer<Float>
    private let greenStorage: UnsafeMutableBufferPointer<Float>
    private let blueStorage: UnsafeMutableBufferPointer<Float>
    private var distances: UnsafeMutableBufferPointer<Float>
    
    /// The array of `k` centroids.
    private var centroids: [Centroid] = []
    
    @concurrent
    static func dominantColors(in image: CGImage) async -> [DominantColor] {
        do {
            let calculator = try DominantColorsCalculator(for: image)
            return calculator.calculate()
        } catch {
            Logger.Standard.general.error(
                """
                DominantColorsCalculator.dominantColors(in:) – Failed to initialize DominantColorsCalculator.
                """
            )
            return []
        }
    }
    
    private init(for image: CGImage) throws {
        guard var format = vImage_CGImageFormat(
            bitsPerComponent: 32,
            bitsPerPixel: 32 * 4,
            colorSpace: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(
                rawValue: kCGBitmapByteOrder32Host.rawValue |
                CGBitmapInfo.floatComponents.rawValue |
                CGImageAlphaInfo.premultipliedLast.rawValue)
        ) else {
            throw DominantColorsCalculatorError.unsupportedImageFormat
        }
        
        let sources: [vImage.PixelBuffer<vImage.PlanarF>] = try vImage.PixelBuffer<vImage.InterleavedFx4>(
            cgImage: image,
            cgImageFormat: &format
        ).planarBuffers()
        
        let scaledPixelCount = Self.dimension * Self.dimension
        let scaled = sources.map { _ in
            UnsafeMutableBufferPointer<Float>.allocate(capacity: scaledPixelCount)
        }
        defer { scaled.forEach { $0.deallocate() } }
        
        for (source, storage) in zip(sources, scaled) {
            let destination = vImage.PixelBuffer<vImage.PlanarF>(
                data: storage.baseAddress!,
                width: Self.dimension,
                height: Self.dimension,
                byteCountPerRow: Self.dimension * MemoryLayout<Float>.stride)
            source.scale(destination: destination)
        }
        
        let (scaledRed, scaledGreen, scaledBlue, scaledAlpha) = (scaled[0], scaled[1], scaled[2], scaled[3])
        
        var red: [Float] = [], green: [Float] = [], blue: [Float] = []
        red.reserveCapacity(scaledPixelCount)
        green.reserveCapacity(scaledPixelCount)
        blue.reserveCapacity(scaledPixelCount)
        
        for i in 0 ..< scaledPixelCount where scaledAlpha[i] >= Self.alphaThreshold {
            let alpha = scaledAlpha[i]
            red.append(min(scaledRed[i] / alpha, 1))
            green.append(min(scaledGreen[i] / alpha, 1))
            blue.append(min(scaledBlue[i] / alpha, 1))
        }
        
        guard red.count >= Self.k else {
            throw DominantColorsCalculatorError.insufficientOpaquePixels
        }
        
        pixelCount = red.count
        redStorage = .allocate(capacity: pixelCount)
        greenStorage = .allocate(capacity: pixelCount)
        blueStorage = .allocate(capacity: pixelCount)
        distances = .allocate(capacity: pixelCount * Self.k)
        
        _ = redStorage.initialize(fromContentsOf: red)
        _ = greenStorage.initialize(fromContentsOf: green)
        _ = blueStorage.initialize(fromContentsOf: blue)
    }
    
    deinit {
        redStorage.deallocate()
        greenStorage.deallocate()
        blueStorage.deallocate()
        distances.deallocate()
    }
    
    private func calculate() -> [DominantColor] {
        initializeCentroids()
        
        for _ in 0 ..< Self.maxIterations {
            do {
                try Task.checkCancellation()
                if updateCentroids() { break }
            } catch {
                Logger.Standard.general.info("DominantColorsCalculator.calculate() - Task cancelled.")
                return []
            }
        }
        
        return centroids.map { DominantColor($0, totalPixelCount: pixelCount) }
    }
    
    private func initializeCentroids() {
        centroids.removeAll()
        
        let randomIndex = Int.random(in: 0 ..< pixelCount)
        centroids.append(Centroid(red: redStorage[randomIndex],
                                  green: greenStorage[randomIndex],
                                  blue: blueStorage[randomIndex]))
        
        let tmp = UnsafeMutableBufferPointer(start: distances.baseAddress!,
                                             count: pixelCount)
        for i in 1 ..< Self.k {
            distanceSquared(x0: greenStorage.baseAddress!, x1: centroids[i - 1].green,
                            y0: blueStorage.baseAddress!, y1: centroids[i - 1].blue,
                            z0: redStorage.baseAddress!, z1: centroids[i - 1].red,
                            n: greenStorage.count,
                            result: tmp.baseAddress!)
            
            let randomIndex = weightedRandomIndex(tmp)
            
            centroids.append(Centroid(red: redStorage[randomIndex],
                                      green: greenStorage[randomIndex],
                                      blue: blueStorage[randomIndex]))
        }
    }
    
    private func updateCentroids() -> Bool {
        let pixelCounts = centroids.map { $0.pixelCount }
        
        populateDistances()
        let centroidIndices = makeCentroidIndices()
        
        for centroid in centroids.enumerated() {
            
            let indices = centroidIndices.enumerated().filter {
                $0.element == centroid.offset
            }.map {
                // `vDSP.gather` uses one-based indices.
                UInt($0.offset + 1)
            }
            
            centroids[centroid.offset].pixelCount = indices.count
            
            if !indices.isEmpty {
                let gatheredRed = vDSP.gather(redStorage,
                                              indices: indices)
                
                let gatheredGreen = vDSP.gather(greenStorage,
                                                indices: indices)
                
                let gatheredBlue = vDSP.gather(blueStorage,
                                               indices: indices)
                
                centroids[centroid.offset].red = vDSP.mean(gatheredRed)
                centroids[centroid.offset].green = vDSP.mean(gatheredGreen)
                centroids[centroid.offset].blue = vDSP.mean(gatheredBlue)
            }
        }
        
        return pixelCounts.elementsEqual(centroids.map { return $0.pixelCount }) { a, b in
            return abs(a - b) < Self.tolerance
        }
    }
    
    private func populateDistances() {
        for centroid in centroids.enumerated() {
            distanceSquared(x0: greenStorage.baseAddress!, x1: centroid.element.green,
                            y0: blueStorage.baseAddress!, y1: centroid.element.blue,
                            z0: redStorage.baseAddress!, z1: centroid.element.red,
                            n: greenStorage.count,
                            result: distances.baseAddress!.advanced(by: pixelCount * centroid.offset))
        }
    }
    
    private func makeCentroidIndices() -> [Int32] {
        let base = distances.baseAddress!
        
        // Start with the first centroid's row as the running minimum.
        var minimumDistances = [Float](UnsafeBufferPointer(start: base, count: pixelCount))
        var indices = [Int32](repeating: 0, count: pixelCount)
        
        for centroidIndex in 1 ..< centroids.count {
            let row = base.advanced(by: pixelCount * centroidIndex)
            for pixel in 0 ..< pixelCount where row[pixel] < minimumDistances[pixel] {
                minimumDistances[pixel] = row[pixel]
                indices[pixel] = Int32(centroidIndex)
            }
        }
        
        return indices
    }
    
    private func weightedRandomIndex(_ weights: UnsafeMutableBufferPointer<Float>) -> Int {
        var outputDescriptor = BNNSNDArrayDescriptor.allocateUninitialized(
            scalarType: Float.self,
            shape: .vector(1))
        
        var probabilities = BNNSNDArrayDescriptor(
            data: weights,
            shape: .vector(weights.count))!
        
        let randomGenerator = BNNSCreateRandomGenerator(
            BNNSRandomGeneratorMethodAES_CTR,
            nil)
        
        BNNSRandomFillCategoricalFloat(
            randomGenerator, &outputDescriptor, &probabilities, false)
        
        defer {
            BNNSDestroyRandomGenerator(randomGenerator)
            outputDescriptor.deallocate()
        }
        
        return Int(outputDescriptor.makeArray(of: Float.self)!.first!)
    }
    
    private func distanceSquared(
        x0: UnsafePointer<Float>, x1: Float,
        y0: UnsafePointer<Float>, y1: Float,
        z0: UnsafePointer<Float>, z1: Float,
        n: Int,
        result: UnsafeMutablePointer<Float>) {
            
            var x = subtract(a: x0, b: x1, n: n)
            vDSP.square(x, result: &x)
            
            var y = subtract(a: y0, b: y1, n: n)
            vDSP.square(y, result: &y)
            
            var z = subtract(a: z0, b: z1, n: n)
            vDSP.square(z, result: &z)
            
            vDSP_vadd(x, 1, y, 1, result, 1, vDSP_Length(n))
            vDSP_vadd(result, 1, z, 1, result, 1, vDSP_Length(n))
        }
    
    private func subtract(a: UnsafePointer<Float>, b: Float, n: Int) -> [Float] {
        return [Float](unsafeUninitializedCapacity: n) {
            buffer, count in
            
            vDSP_vsub(a, 1,
                      [b], 0,
                      buffer.baseAddress!, 1,
                      vDSP_Length(n))
            
            count = n
        }
    }
}
