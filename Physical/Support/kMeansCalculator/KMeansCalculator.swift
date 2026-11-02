//
//  KMeansCalculator.swift
//  Untitled Project
//
//  Created by Spencer Hartland on 10/30/26.
//

import Accelerate
import SwiftUI
import Observation

@MainActor
@Observable
class KMeansCalculator {
    private static let k: Int = 5
    private static let maxIterations: Int = 64
    private static let dimension: Int = 256
    private static let channelCount: Int = 3
    private static let tolerance: Int = 10
    
    /// The Core Graphics image format.
    private var rgbImageFormat = vImage_CGImageFormat(
        bitsPerComponent: 32,
        bitsPerPixel: 32 * 3,
        colorSpace: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGBitmapInfo(
            rawValue: kCGBitmapByteOrder32Host.rawValue |
            CGBitmapInfo.floatComponents.rawValue |
            CGImageAlphaInfo.none.rawValue))!
    
    /// Storage for a matrix with `dimension * dimension` columns and `k` rows that stores the
    /// distances squared of each pixel color for each centroid.
    private var distances: UnsafeMutableBufferPointer<Float>!
    
    /// The storage and pixel buffer for each red value.
    private let redStorage = UnsafeMutableBufferPointer<Float>.allocate(capacity: dimension * dimension)
    private let redBuffer: vImage.PixelBuffer<vImage.PlanarF>
    
    /// The storage and pixel buffer for each green value.
    private let greenStorage = UnsafeMutableBufferPointer<Float>.allocate(capacity: dimension * dimension)
    private let greenBuffer: vImage.PixelBuffer<vImage.PlanarF>
    
    /// The storage and pixel buffer for each blue value.
    private let blueStorage = UnsafeMutableBufferPointer<Float>.allocate(capacity: dimension * dimension)
    private let blueBuffer: vImage.PixelBuffer<vImage.PlanarF>
    
    /// The array of `k` centroids.
    private var centroids = [Centroid]()
    
    var isBusy: Bool = true
    
    var sourceImage: UIImage? {
        didSet {
            print("Calculating...")
            calculateKMeans()
        }
    }
    
    var dominantColors = [DominantColor]()
    
    init() {
        redBuffer = vImage.PixelBuffer<vImage.PlanarF>(
            data: redStorage.baseAddress!,
            width: Self.dimension,
            height: Self.dimension,
            byteCountPerRow: Self.dimension * MemoryLayout<Float>.stride)
        
        greenBuffer = vImage.PixelBuffer<vImage.PlanarF>(
            data: greenStorage.baseAddress!,
            width: Self.dimension,
            height: Self.dimension,
            byteCountPerRow: Self.dimension * MemoryLayout<Float>.stride)
        
        blueBuffer = vImage.PixelBuffer<vImage.PlanarF>(
            data: blueStorage.baseAddress!,
            width: Self.dimension,
            height: Self.dimension,
            byteCountPerRow: Self.dimension * MemoryLayout<Float>.stride)
        
        allocateDistancesBuffer()
    }
    
    isolated deinit {
        redStorage.deallocate()
        greenStorage.deallocate()
        blueStorage.deallocate()
        
        distances.deallocate()
    }
    
    /// Allocates the memory required for the distances matrix.
    private func allocateDistancesBuffer() {
        if distances != nil {
            distances.deallocate()
        }
        distances = UnsafeMutableBufferPointer<Float>.allocate(capacity: Self.dimension * Self.dimension * Self.k)
    }
    
    /// Calculates k-means for the selected thumbnail.
    private func calculateKMeans() {
        guard let image = sourceImage?.cgImage else {
            print("Couldn't get cgImage.")
            return
        }
        
        let rgbSources: [vImage.PixelBuffer<vImage.PlanarF>] = try! vImage.PixelBuffer<vImage.InterleavedFx3>(
            cgImage: image,
            cgImageFormat: &rgbImageFormat).planarBuffers()
        
        rgbSources[0].scale(destination: redBuffer)
        rgbSources[1].scale(destination: greenBuffer)
        rgbSources[2].scale(destination: blueBuffer)
        
        isBusy = true
        
        initializeCentroids()
        update()
    }
    
    /// Iterates over the `updateCentroids` function until the solution converges or the
    /// iteration count equals `maximumIterations`.
    private func update() {
        Task {
            var converged = false
            var iterationCount = 0
            
            while !converged && iterationCount < Self.maxIterations {
                converged = updateCentroids()
                iterationCount += 1
            }
            
            DispatchQueue.main.async { [self] in
                dominantColors = centroids.map {
                    DominantColor($0)
                }
                isBusy = false
                print("Done! isBusy: \(isBusy), colors: \(dominantColors.count)")
            }
        }
    }
    
    /// - Tag: initializeCentroids
    private func initializeCentroids() {
        centroids.removeAll()
        
        let randomIndex = Int.random(in: 0 ..< Self.dimension * Self.dimension)
        centroids.append(Centroid(red: redStorage[randomIndex],
                                  green: greenStorage[randomIndex],
                                  blue: blueStorage[randomIndex]))
        
        // Use the first row of the `distances` buffer as temporary storage.
        let tmp = UnsafeMutableBufferPointer(start: distances.baseAddress!,
                                             count: Self.dimension * Self.dimension)
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
    
    /// Updates centroids and returns true if pixel counts haven't changed (that is, the solution converged).
    ///
    /// 1. Create k random centroids selected from the RGB colors in an image.
    /// 2. Create a distances matrix that has pixel-count columns and k rows.
    /// 3. For each centroid, populate the corresponding row in distances matrix with the distance-squared
    /// between it and each matrix.
    /// 4. Use BNNS reduction argMin on the distances matrix to create a vector with pixel-count elements.
    /// Each element in the vector is the centroid that's the closest color to the corresponding pixel.
    /// 5. For each centroid, use BNNS gather to create a new vector for each RGB channel of the pixel
    /// colors for that centroid. Compute the mean value of that vector and set the centroid color to that average.
    /// 6. Repeat steps 3, 4, and 5 until the solution converges.
    /// - Tag: updateCentroids
    private func updateCentroids() -> Bool {
        // The pixel counts per centroid before this iteration.
        let pixelCounts = centroids.map { $0.pixelCount }
        
        populateDistances()
        let centroidIndices = makeCentroidIndices()
        
        for centroid in centroids.enumerated() {
            
            // The indices into the red, green, and blue descriptors for this centroid.
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
    
    /// Populates the `distances` memory with the distance squared between each centroid and each color.
    private func populateDistances() {
        for centroid in centroids.enumerated() {
            distanceSquared(x0: greenStorage.baseAddress!, x1: centroid.element.green,
                            y0: blueStorage.baseAddress!, y1: centroid.element.blue,
                            z0: redStorage.baseAddress!, z1: centroid.element.red,
                            n: greenStorage.count,
                            result: distances.baseAddress!.advanced(by: Self.dimension * Self.dimension * centroid.offset))
        }
    }
    
    /// Returns the index of the closest centroid for each color.
    ///
    /// The `distances` buffer stores one row of `dimension * dimension` distances per centroid,
    /// so this computes the argmin down each column.
    private func makeCentroidIndices() -> [Int32] {
        let pixelCount = Self.dimension * Self.dimension
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

extension KMeansCalculator {
    /// A structure that represents a centroid.
    @MainActor
    struct Centroid {
        /// The red channel value.
        var red: Float
        
        /// The green channel value.
        var green: Float
        
        /// The blue channel value.
        var blue: Float
        
        /// The number of pixels assigned to this cluster center.
        var pixelCount: Int = 0
    }
    
    /// A structure that represents a dominant color.
    @MainActor
    struct DominantColor: Identifiable, Comparable {
        init(_ centroid: Centroid) {
            self.color = Color(red: Double(centroid.red), green: Double(centroid.green), blue: Double(centroid.blue))
            self.percentage = Int(Float(centroid.pixelCount) / Float(dimension * dimension) * 100)
        }
        
        init(color: Color, percentage: Int) {
            self.color = color
            self.percentage = percentage
        }
        
        static func < (lhs: DominantColor, rhs: DominantColor) -> Bool {
            return lhs.percentage < rhs.percentage
        }
        
        var id = UUID()
        
        let color: Color
        let percentage: Int
    }
}
