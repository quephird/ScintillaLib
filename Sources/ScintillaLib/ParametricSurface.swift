//
//  ParametricSurface.swift
//
//
//  Created by Danielle Kefford on 10/29/23.
//

import Darwin

public typealias ParametricFunction = (Double, Double) -> Double

let MAX_SECTOR_NUM = 10_000_000

@_spi(Testing) public enum UV {
    case none
    case value(Double, Double)
}

public class ParametricSurface: Shape {
    var fx: ParametricFunction
    var fy: ParametricFunction
    var fz: ParametricFunction
    var boundingShape: Shape
    var uRange: (Double, Double)
    var vRange: (Double, Double)

    var accuracy = 0.001
    var maxGradient = 1.0

    public convenience init(_ bottomFrontLeft: Point3D,
                            _ topBackRight: Point3D,
                            _ uRange: (Double, Double),
                            _ vRange: (Double, Double),
                            _ fx: @escaping ParametricFunction,
                            _ fy: @escaping ParametricFunction,
                            _ fz: @escaping ParametricFunction) {
        let (xMin, yMin, zMin) = bottomFrontLeft
        let (xMax, yMax, zMax) = topBackRight
        let (scaleX, scaleY, scaleZ) = ((xMax-xMin)/2, (yMax-yMin)/2, (zMax-zMin)/2)
        let (translateX, translateY, translateZ) = ((xMax+xMin)/2, (yMax+yMin)/2, (zMax+zMin)/2)
        let boundingShape = Cube()
            .scale(scaleX, scaleY, scaleZ)
            .translate(translateX, translateY, translateZ)
        self.init(boundingShape, uRange, vRange, fx, fy, fz)
    }

    public init(_ boundingShape: Shape,
                _ uRange: (Double, Double),
                _ vRange: (Double, Double),
                _ fx: @escaping ParametricFunction,
                _ fy: @escaping ParametricFunction,
                _ fz: @escaping ParametricFunction) {
        self.boundingShape = boundingShape
        self.uRange = uRange
        self.vRange = vRange
        self.fx = fx
        self.fy = fy
        self.fz = fz
    }

    let INDEX_U = 0
    let INDEX_V = 1

    @_spi(Testing) public override func localIntersect(_ localRay: Ray) -> [Intersection] {
        // First we check to see if the ray intersects the bounding shape;
        // note that we need a pair of hits in order to construct a range
        // of values for t below...
        let boundingBoxIntersections = self.boundingShape.intersect(localRay)
        guard boundingBoxIntersections.count == 2 else {
            return []
        }

        let t1 = boundingBoxIntersections[0].t
        let t2 = boundingBoxIntersections[1].t
        let rayOrigin = localRay.origin
        let rayDirection = localRay.direction

        let (uMin, uMax) = self.uRange
        let (vMin, vMax) = self.vRange

        var intervalsLow = [[Double]](repeating: [Double](repeating: 0.0, count: 32), count: 2)
        var intervalsHigh = [[Double]](repeating: [Double](repeating: 0.0, count: 32), count: 2)
        var sectorNum = [Int](repeating: 0, count: 32)

        intervalsLow[INDEX_U][0] = uMin;
        intervalsHigh[INDEX_U][0] = uMax;
        intervalsLow[INDEX_V][0] = vMin;
        intervalsHigh[INDEX_V][0] = vMax;

        sectorNum[0] = 1;

        var t = Double.infinity
        var uv: UV = .none
        var potentialT = Double.infinity
        var deltaT: Double
        var lowUV: (Double, Double)
        var highUV: (Double, Double)
        var minTForX = 0.0
        var maxTForX = 0.0
        var minTForY = 0.0
        var maxTForY = 0.0
        var minTForZ = 0.0
        var maxTForZ = 0.0
        var i = 0

        while i >= 0 {
            lowUV = (intervalsLow[INDEX_U][i], intervalsLow[INDEX_V][i])
            highUV = (intervalsHigh[INDEX_U][i], intervalsHigh[INDEX_V][i])

            var maxSectorWidth = highUV.0 - lowUV.0
            var splitIndex = INDEX_U

            let tempSectorWidth = highUV.1 - lowUV.1
            if tempSectorWidth > maxSectorWidth {
                maxSectorWidth = tempSectorWidth
                splitIndex = INDEX_V
            }

            var parX = false
            var parY = false
            deltaT = 0.0

            // Start narrowing down the value of t based on the range of values for the x coordinate
            var lowX: Double
            var highX: Double
            (lowX, highX) = computeIntervalForSector(fn: self.fx,
                                                     accuracy: self.accuracy,
                                                     lowUV: lowUV,
                                                     highUV: highUV,
                                                     maxGradient: self.maxGradient)

            if rayDirection.x.isAlmostEqual(0.0) {
                parX = true

                if highX < rayOrigin.x || lowX < rayOrigin.x {
                    i -= 1
                    continue
                }
            } else {
                minTForX = (highX - rayOrigin.x)/rayDirection.x
                maxTForX = (lowX - rayOrigin.x)/rayDirection.x

                if (minTForX > maxTForX) {
                    (minTForX, maxTForX) = (maxTForX, minTForX)
                }

                if (minTForX > t2) || (maxTForX < t1) {
                    i -= 1
                    continue
                }

                potentialT = minTForX
                if potentialT > t {
                    i -= 1
                    continue
                }

                deltaT = maxTForX - minTForX;
            }

            // Continue narrowing down t based on the range of values for the y coordinate
            var lowY: Double
            var highY: Double
            (lowY, highY) = computeIntervalForSector(fn: self.fy,
                                                     accuracy: self.accuracy,
                                                     lowUV: lowUV,
                                                     highUV: highUV,
                                                     maxGradient: self.maxGradient)

            if rayDirection.y.isAlmostEqual(0.0) {
                parY = true

                if highY < rayOrigin.y || lowY < rayOrigin.y {
                    i -= 1
                    continue
                }
            } else {
                minTForY = (highY - rayOrigin.y)/rayDirection.y
                maxTForY = (lowY - rayOrigin.y)/rayDirection.y

                if (minTForY > maxTForY) {
                    (minTForY, maxTForY) = (maxTForY, minTForY)
                }

                if (minTForY > t2) || (maxTForY < t1) {
                    i -= 1
                    continue
                }

                potentialT = minTForY
                if potentialT > t {
                    i -= 1
                    continue
                }

                if parX {
                    if (minTForY > maxTForX) || (maxTForY < minTForX) {
                        i -= 1
                        continue
                    }
                }

                let temp = maxTForY - minTForY
                if temp > deltaT {
                    deltaT = temp
                }
            }

            // Now continue narrowing down t based on the range of values for the z coordinate
            var lowZ: Double
            var highZ: Double
            (lowZ, highZ) = computeIntervalForSector(fn: self.fz,
                                                     accuracy: self.accuracy,
                                                     lowUV: lowUV,
                                                     highUV: highUV,
                                                     maxGradient: self.maxGradient)

            if rayDirection.z.isAlmostEqual(0.0) {
                parY = true

                if highZ < rayOrigin.z || lowZ < rayOrigin.z {
                    i -= 1
                    continue
                }
            } else {
                minTForZ = (highZ - rayOrigin.z)/rayDirection.z
                maxTForZ = (lowZ - rayOrigin.z)/rayDirection.z

                if (minTForZ > maxTForZ) {
                    (minTForZ, maxTForZ) = (maxTForZ, minTForZ)
                }

                if (minTForZ > t2) || (maxTForZ < t1) {
                    i -= 1
                    continue
                }

                potentialT = minTForZ
                if potentialT > t {
                    i -= 1
                    continue
                }

                if parX {
                    if (minTForZ > maxTForX) || (maxTForZ < minTForX) {
                        i -= 1
                        continue
                    }
                }
                if parY {
                    if (minTForZ > maxTForY) || (maxTForZ < minTForY) {
                        i -= 1
                        continue
                    }
                }

                let temp = maxTForZ - minTForZ
                if temp > deltaT {
                    deltaT = temp
                }
            }

            if maxSectorWidth > deltaT {
                maxSectorWidth = deltaT
            }

            if maxSectorWidth < accuracy {
                if (t > potentialT) && (potentialT > t1) {
                    t = potentialT
                    uv = .value(lowUV.0, lowUV.1)
                }

                i -= 1
            } else {
                sectorNum[i] *= 2
                if sectorNum[i] > MAX_SECTOR_NUM {
                    sectorNum[i] = MAX_SECTOR_NUM
                }

                sectorNum[i+1] = sectorNum[i]
                sectorNum[i] += 1

                i += 1

                intervalsLow[INDEX_U][i] = lowUV.0
                intervalsHigh[INDEX_U][i] = highUV.0
                intervalsLow[INDEX_V][i] = lowUV.1
                intervalsHigh[INDEX_V][i] = highUV.1

                let temp = (intervalsHigh[splitIndex][i] + intervalsLow[splitIndex][i]) / 2.0
                intervalsHigh[splitIndex][i] = temp
                intervalsLow[splitIndex][i-1] = temp
            }
        }

        if t < t2 {
            let intersection = Intersection(t, uv, self)
            return [intersection]
        }


        return []
    }

    @_spi(Testing) public override func localNormal(_ localPoint: Point, _ uv: UV) -> Vector {
        switch uv {
        case .value(let u, let v):
            let gradFxu = (fx(u + DELTA, v) - fx(u, v))/DELTA
            let gradFxv = (fx(u, v + DELTA) - fx(u, v))/DELTA
            let gradFyu = (fy(u + DELTA, v) - fy(u, v))/DELTA
            let gradFyv = (fy(u, v + DELTA) - fy(u, v))/DELTA
            let gradFzu = (fz(u + DELTA, v) - fz(u, v))/DELTA
            let gradFzv = (fz(u, v + DELTA) - fz(u, v))/DELTA

            let gradFu = Vector(gradFxu, gradFyu, gradFzu)
            let gradFv = Vector(gradFxv, gradFyv, gradFzv)

            return gradFu.cross(gradFv).normalize()
        default:
            fatalError("Whoops... you need to pass in a uv pair!")
        }
    }

    private func computeIntervalForEdge(deltaY: Double,
                                        x1: Double,
                                        x2: Double,
                                        maxGradient: Double) -> (Double, Double) {
        let deltaX = abs(x2 - x1)
        var offset = maxGradient*(deltaY - deltaX/maxGradient)/2.0

        if offset < 0 {
            offset = 0
        }

        return (min(x1, x2)-offset, max(x1, x2)+offset)
    }

    private func computeIntervalForSector(fn: ParametricFunction,
                                  accuracy: Double,
                                  lowUV: (Double, Double),
                                  highUV: (Double, Double),
                                  maxGradient: Double) -> (Double, Double) {
        /* Calculate the values at each corner */
        let bottomLeft = fn(lowUV.0, lowUV.1) - accuracy
        let topLeft = fn(lowUV.0, highUV.1) - accuracy
        let bottomRight = fn(highUV.0, lowUV.1) - accuracy
        let topRight = fn(highUV.0, highUV.1) - accuracy

        let deltaU = highUV.0 - lowUV.0
        let deltaV = highUV.1 - lowUV.1

        /* Determine a min and a max along the left edge of the sector */
        let (leftEdgeMin, leftEdgeMax) = computeIntervalForEdge(deltaY: deltaV,
                                                                x1: bottomLeft,
                                                                x2: topLeft,
                                                                maxGradient: self.maxGradient)

        /* Determine a min and a max along the right edge of the sector */
        let (rightEdgeMin, rightEdgeMax) = computeIntervalForEdge(deltaY: deltaV,
                                                                  x1: bottomRight,
                                                                  x2: topRight,
                                                                  maxGradient: self.maxGradient)

        /* Assume that the upper bounds of both edges are attained at the same
         u coordinate and determine what an upper bound along that line would
         be if it existed.  That's the worst-case maximum value we can reach. */
        let (_, high) = computeIntervalForEdge(deltaY: deltaU,
                                               x1: leftEdgeMax,
                                               x2: rightEdgeMax,
                                               maxGradient: self.maxGradient)

        /* same as above to get a lower bound from the two edge lower bounds */
        let (low, _) = computeIntervalForEdge(deltaY: deltaU,
                                              x1: leftEdgeMin,
                                              x2: rightEdgeMin,
                                              maxGradient: self.maxGradient)

        return (low, high)
    }
}
