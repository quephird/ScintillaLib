//
//  ParametricSurface.swift
//
//
//  Created by Danielle Kefford on 10/29/23.
//

import Darwin

public typealias ParametricFunction = (Double, Double) -> Double

let MAX_SECTOR_NUM = 10_000_000
let DEFAULT_ACCURACY = 0.001
let DEFAULT_MAX_GRADIENT = 1.0

@_spi(Testing) public enum UV {
    case none
    case value(Double, Double)
}

struct Sector {
    var lowUV: (Double, Double)
    var highUV: (Double, Double)
}

public class ParametricSurface: Shape {
    var fx: ParametricFunction
    var fy: ParametricFunction
    var fz: ParametricFunction
    var boundingShape: Shape
    var uRange: (Double, Double)
    var vRange: (Double, Double)
    var accuracy: Double
    var maxGradient: Double

    public convenience init(_ bottomFrontLeft: Point3D,
                            _ topBackRight: Point3D,
                            _ uRange: (Double, Double),
                            _ vRange: (Double, Double),
                            _ accuracy: Double,
                            _ maxGradient: Double,
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
        self.init(boundingShape, uRange, vRange, accuracy, maxGradient, fx, fy, fz)
    }

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
        self.init(boundingShape, uRange, vRange, DEFAULT_ACCURACY, DEFAULT_MAX_GRADIENT, fx, fy, fz)
    }

    public init(_ boundingShape: Shape,
                _ uRange: (Double, Double),
                _ vRange: (Double, Double),
                _ accuracy: Double,
                _ maxGradient: Double,
                _ fx: @escaping ParametricFunction,
                _ fy: @escaping ParametricFunction,
                _ fz: @escaping ParametricFunction) {
        self.boundingShape = boundingShape
        self.uRange = uRange
        self.vRange = vRange
        self.accuracy = accuracy
        self.maxGradient = maxGradient
        self.fx = fx
        self.fy = fy
        self.fz = fz
    }

    // NOTA BENE: This method only ever returns a maximum of one intersection,
    // that being the closest one to the camera.
    @_spi(Testing) public override func localIntersect(_ localRay: Ray) -> [Intersection] {
        // First we check to see if the ray intersects the bounding shape;
        // note that we need a pair of hits in order to construct a range
        // of values for t below...
        let boundingBoxIntersections = self.boundingShape.intersect(localRay)
        guard boundingBoxIntersections.count == 2 else {
            return []
        }

        // Capture the t values for the intersections; these will be used
        // in the loop below to filter out candidate intersections that
        // fall outside the bounding box.
        let t1 = boundingBoxIntersections[0].t
        let t2 = boundingBoxIntersections[1].t

        let rayOrigin    = localRay.origin
        let rayDirection = localRay.direction

        // uvSectors is effectively a stack, used in the main loop below
        // to track which parts of the (u, v) space have searched for
        // intersections.
        var uvSectors = [Sector](repeating: Sector(lowUV: (0, 0), highUV: (0, 0)), count: 32)
        uvSectors[0].lowUV  = (self.uRange.0, self.vRange.0)
        uvSectors[0].highUV = (self.uRange.1, self.vRange.1)

        var t: Double? = nil
        var uv: UV = .none

        // This loop effectively treats uvSectors as a stack, the top of which the loop below
        // always operates, using i as a pointer to the top. Each iteration examines the current
        // sector, bounded by the low and high values for u and v. Generally speaking, we compute
        // ranges of t values first for x, then for y, and then finally for z, and if all three
        // ranges overlap, _and_ the width of the "cube" formed by the ranges of values for t, u, and v
        // is less than the desired accuracy, then we capture the values for t, u, and v.
        // We then continue refining t, u, and v, until the stack is effectively empty (when i is -1).
        // Note that each time we capture a value for t, it is always smaller than the previous
        // one captured. It is that final set of values of t, u, and v that represents an intersection.
        // The assumption is once i reaches -1, we have either found the closest intersection _or_
        // we have sufficiently and exhaustively searched (t,u,v) space for one and failed.
        //
        // TODO: Explain how we are guaranteed to exit this loop, and how we are
        // sure that the computed t value is provably the closest possible to the camera
        var i = 0
        while i >= 0 {
            let lowUV  = uvSectors[i].lowUV
            let highUV = uvSectors[i].highUV

            // These variables will be used in the final part of the loop
            // to refine the cube formed by the ranges of values of each of
            // t, u, and v. That is, we want to find a cube whose width
            // is as clase as possible to the accuracy parameter associsated
            // with the shape; that way we can be most confident that we have
            // found an intersection.
            //
            //                          ___________
            //                         /          /|
            //                        /_________ / |
            //                       |          |  |
            //                deltaV |          |  /
            //                       |          | / deltaT
            //                       |__________|/
            //                          deltaU
            //
            let deltaU = highUV.0 - lowUV.0
            let deltaV = highUV.1 - lowUV.1
            var deltaT = 0.0

            // We start with the largest possible value of t, and each time we are
            // able to compute a range of t values associated with the fx, fy, and fz
            // functions, we will capture a candidate value of t if it is smaller than
            // the previous value.
            var potentialT = Double.infinity

            // These variables are used to capture whether or not we have found
            // a range of values for t while examining the functions associated with
            // the x and y coordinates.
            var rangeTForX: (Double, Double)? = nil
            var rangeTForY: (Double, Double)? = nil

            // Here is where we begin narrowing down the value of t,
            // based on the range of values for the x coordinate.
            //
            // First we approximate the mininum and maximum values of x
            // using its correspondent function, fx, over the sector defined
            // by lowUV and highUV.
            let (lowX, highX) = computeIntervalForSector(fn: self.fx,
                                                         accuracy: self.accuracy,
                                                         lowUV: lowUV,
                                                         highUV: highUV,
                                                         maxGradient: self.maxGradient)

            // Next we need to convert those x values to t values.
            //
            // If the x component of the ray's direction is near zero,
            // then we cannot accurately compute correspondent values of t.
            if rayDirection.x.isAlmostEqual(0.0) {
                if highX < rayOrigin.x || lowX > rayOrigin.x {
                    i -= 1
                    continue
                }
            } else {
                var minTForX = (lowX - rayOrigin.x)/rayDirection.x
                var maxTForX = (highX - rayOrigin.x)/rayDirection.x

                if (minTForX > maxTForX) {
                    (minTForX, maxTForX) = (maxTForX, minTForX)
                }

                // If the range of the new t values is outside the bounding box,
                // then we need to consider the previous sector.
                if (minTForX > t2) || (maxTForX < t1) {
                    i -= 1
                    continue
                }

                // If the lesser of the newly computed t values is larger than the
                // previously computed t, then we need to consider the previous sector.
                potentialT = minTForX
                if let t = t, potentialT > t {
                    i -= 1
                    continue
                }

                // Capture the range of values of t for the x coordinate and its range.
                rangeTForX = (minTForX, maxTForX)
                deltaT = maxTForX - minTForX;
            }

            // Continue narrowing down t based on the range of values for the y coordinate.
            let (lowY, highY) = computeIntervalForSector(fn: self.fy,
                                                         accuracy: self.accuracy,
                                                         lowUV: lowUV,
                                                         highUV: highUV,
                                                         maxGradient: self.maxGradient)

            // As for the x coordinate, we need to convert y values to t values.
            if rayDirection.y.isAlmostEqual(0.0) {
                if highY < rayOrigin.y || lowY > rayOrigin.y {
                    i -= 1
                    continue
                }
            } else {
                var minTForY = (lowY - rayOrigin.y)/rayDirection.y
                var maxTForY = (highY - rayOrigin.y)/rayDirection.y

                if (minTForY > maxTForY) {
                    (minTForY, maxTForY) = (maxTForY, minTForY)
                }

                // If the range of the new t values is outside the bounding box,
                // then we need to consider the previous sector.
                if (minTForY > t2) || (maxTForY < t1) {
                    i -= 1
                    continue
                }

                // If the lesser of the newly computed t values is larger than the
                // previously computed t, then we need to consider the previous sector.
                potentialT = minTForY
                if let t = t, potentialT > t {
                    i -= 1
                    continue
                }

                // If we previously computed a range of potential t values
                // while examining the x coordinate, _and_ that range does not
                // overlap the range of t values for the y coordinate, then
                // we need to consider the previous sector.
                if let (minTForX, maxTForX) = rangeTForX {
                    if (minTForY > maxTForX) || (maxTForY < minTForX) {
                        i -= 1
                        continue
                    }
                }

                // Capture the computed range of values of t for the y coordinate,
                // and if its range is bigger than the current value of deltaT,
                // then capture that as the new value for deltaT.
                rangeTForY = (minTForY, maxTForY)
                let temp = maxTForY - minTForY
                if temp > deltaT {
                    deltaT = temp
                }
            }

            // Finally, continue narrowing down t based on the range of values for the z coordinate
            let (lowZ, highZ) = computeIntervalForSector(fn: self.fz,
                                                         accuracy: self.accuracy,
                                                         lowUV: lowUV,
                                                         highUV: highUV,
                                                         maxGradient: self.maxGradient)

            // As for the x and y coordinates, we need to convert z values to t values.
            if rayDirection.z.isAlmostEqual(0.0) {
                if highZ < rayOrigin.z || lowZ > rayOrigin.z {
                    i -= 1
                    continue
                }
            } else {
                var minTForZ = (lowZ - rayOrigin.z)/rayDirection.z
                var maxTForZ = (highZ - rayOrigin.z)/rayDirection.z

                if (minTForZ > maxTForZ) {
                    (minTForZ, maxTForZ) = (maxTForZ, minTForZ)
                }

                // If the range of the new t values is outside the bounding box,
                // then we need to consider the previous sector.
                if (minTForZ > t2) || (maxTForZ < t1) {
                    i -= 1
                    continue
                }

                // If the lesser of the newly computed t values is larger than the
                // previously computed t, then we need to consider the previous sector.
                potentialT = minTForZ
                if let t = t, potentialT > t {
                    i -= 1
                    continue
                }

                // If we previously computed a range of potential t values
                // while examining the x coordinate, _and_ that range does not
                // overlap the range of t values for the z coordinate, then
                // we need to consider the previous sector.
                if let (minTForX, maxTForX) = rangeTForX {
                    if (minTForZ > maxTForX) || (maxTForZ < minTForX) {
                        i -= 1
                        continue
                    }
                }
                // Similarly, if we previously computed a range of potential t values
                // while examining the _y_ coordinate, _and_ that range does not
                // overlap the range of t values for the z coordinate, then
                // we need to consider the previous sector.
                if let (minTForY, maxTForY) = rangeTForY {
                    if (minTForZ > maxTForY) || (maxTForZ < minTForY) {
                        i -= 1
                        continue
                    }
                }

                // If the range of t values for the z coordinate is bigger than the
                // current value of deltaT, then capture that as the new value for deltaT.
                let temp = maxTForZ - minTForZ
                if temp > deltaT {
                    deltaT = temp
                }
            }

            // TODO: Figure out why we are taking the _smaller_ of deltaT against the
            // _larger_ of deltaU and deltaV
            let cubeWidth = min(deltaT, max(deltaU, deltaV))

            // If we got here, then we finished processing for all three coordinates,
            // and we have a potential value for t.
            //
            // First we see if the width of the tuv-sector is sufficiently small...
            if cubeWidth < self.accuracy {
                // If we haven't yet set t _or_ the candidate t is closer to the camera
                // than the current t and inside the bounding box, then we capture a new
                // value for t.
                if t == nil || (potentialT < t! && potentialT > t1) {
                    // TODO: Figure out how and why we hit this branch more than the
                    // maximum number of intersections a ray could have with a shape
                    t = potentialT
                    uv = .value(lowUV.0, lowUV.1)
                }

                // OBSERVATION: i appears to never be zero in this block, and thus
                // the loop never immediately terminates right after this statement.
                i -= 1
            } else {
                // If we got here, then we need to refine the values of u or v.
                //
                // First increment i, effectively "pushing" a new sector onto the stack
                i += 1

                // Copy the uv ranges of the previous sector into the new one.
                uvSectors[i].lowUV  = lowUV
                uvSectors[i].highUV = highUV

                // Here we determine which of the u and v parameters whose range
                // we're going to "split" for the next iteration of the loop.
                // Note that we're always going to choose the one whose range is
                // the larger.
                switch deltaU > deltaV {
                case true:
                    // Take the average of the low and high values of u and
                    // shrink the range of u for the new current sector by lowering
                    // its high u value, and shrink the range of the previous sector
                    // by raising its low u value.
                    let newU = (uvSectors[i].lowUV.0 + uvSectors[i].highUV.0)/2.0
                    uvSectors[i].highUV.0  = newU
                    uvSectors[i-1].lowUV.0 = newU
                case false:
                    // Do the same as above but instead for the v values of the current
                    // and previous sectors.
                    let newV = (uvSectors[i].lowUV.1 + uvSectors[i].highUV.1)/2.0
                    uvSectors[i].highUV.1  = newV
                    uvSectors[i-1].lowUV.1 = newV
                }
            }
        }

        // If we got here, then we're finally done iterating to find a t value.
        if let t = t {
            // Note that t has already been tested in the loop above to be inside
            // the bounding box, i.e., that both t > t1 and t < t2
            let intersection = Intersection(t, uv, self)
            return [intersection]
        }

        // No t was ever found; the ray missed and we return an empty list.
        return []
    }

    @_spi(Testing) public override func localNormal(_ localPoint: Point, _ uv: UV) -> Vector {
        // We compute the normal vector by first numerically approximating all the partial
        // derivatives: ∂Fx/∂u, ∂Fy/∂u, ∂Fz/∂u, ∂Fx/∂v, ∂Fy/∂v, ∂Fz/∂v. Then we form the vectors:
        //
        //              ∂Fx    ∂Fy    ∂Fz                  ∂Fx    ∂Fy    ∂Fz
        //              ---i + ---j + ---k       and       ---i + ---j + ---k
        //              ∂u     ∂u     ∂u                   ∂v     ∂v     ∂v
        //
        // and return their normalized cross product. Note that we don't even consider
        // the point passed in, just the values for u and v.
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

    // TODO: Explain what is the thinking behind using deltaY and maxGradient
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

    // This function computes the min and max values for the coordinate
    // correspondent with the parametric function fn passed in over the sector
    // defined by lowUV and highUV.
    private func computeIntervalForSector(fn: ParametricFunction,
                                          accuracy: Double,
                                          lowUV: (Double, Double),
                                          highUV: (Double, Double),
                                          maxGradient: Double) -> (Double, Double) {
        // Calculate the values of fn at each corner of the sector.
        let bottomLeft  = fn(lowUV.0, lowUV.1) - accuracy
        let topLeft     = fn(lowUV.0, highUV.1) - accuracy
        let bottomRight = fn(highUV.0, lowUV.1) - accuracy
        let topRight    = fn(highUV.0, highUV.1) - accuracy

        let deltaU = highUV.0 - lowUV.0
        let deltaV = highUV.1 - lowUV.1

        // Determine min and max values along the left edge of the sector.
        let (leftEdgeMin, leftEdgeMax) = computeIntervalForEdge(deltaY: deltaV,
                                                                x1: bottomLeft,
                                                                x2: topLeft,
                                                                maxGradient: maxGradient)

        // Determine min and max values along the right edge of the sector.
        let (rightEdgeMin, rightEdgeMax) = computeIntervalForEdge(deltaY: deltaV,
                                                                  x1: bottomRight,
                                                                  x2: topRight,
                                                                  maxGradient: maxGradient)

        // Assume that the upper bounds of both edges are attained at the same
        // u coordinate and determine what an upper bound along that line would
        // be if it existed. That's the worst-case maximum value we can reach.
        let (_, high) = computeIntervalForEdge(deltaY: deltaU,
                                               x1: leftEdgeMax,
                                               x2: rightEdgeMax,
                                               maxGradient: maxGradient)

        // Same as above to get a lower bound from the two edge lower bounds.
        let (low, _) = computeIntervalForEdge(deltaY: deltaU,
                                              x1: leftEdgeMin,
                                              x2: rightEdgeMin,
                                              maxGradient: maxGradient)

        return (low, high)
    }
}
