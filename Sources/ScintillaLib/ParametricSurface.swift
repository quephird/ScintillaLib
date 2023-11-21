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

enum ComputeTRangeReturnValue {
    case goToPreviousSector
    case noneFound
    case value(Double, Double)
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
                            _ fx: @escaping ParametricFunction,
                            _ fy: @escaping ParametricFunction,
                            _ fz: @escaping ParametricFunction) {
        self.init(bottomFrontLeft, topBackRight, uRange, vRange, DEFAULT_ACCURACY, DEFAULT_MAX_GRADIENT, fx, fy, fz)
    }

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

    // This function is for computing the range of values for t
    // for a given coordinate and its correspondent parametric function,
    // over the uv-sector. There are several checks to see if the caller
    // should go back to the previous uv-sector in the stack, move onto
    // further processing if no range for t is found, or capture a range
    // of t values.
    private func computeTRangeForCoordinate(fn: ParametricFunction,
                                            rayComponents: (Double, Double),
                                            sector: Sector,
                                            currentT: Double?,
                                            boundingBoxTRange: (Double, Double),
                                            previousTRanges: [(Double, Double)?]) -> ComputeTRangeReturnValue {
        let (t1, t2) = boundingBoxTRange
        let (rayOriginComponent, rayDirectionComponent) = rayComponents

        // First we approximate the mininum and maximum values of the coordinate
        // using its correspondent function, fn, over the sector defined
        // by lowUV and highUV.
        let (low, high) = computeIntervalForSector(fn: fn,
                                                   accuracy: self.accuracy,
                                                   lowUV: sector.lowUV,
                                                   highUV: sector.highUV,
                                                   maxGradient: self.maxGradient)

        // Next we need to convert those values to t values.
        //
        // If the component of the ray's direction is near zero,
        // then we cannot accurately compute correspondent values of t.
        if rayDirectionComponent.isAlmostEqual(0.0) {
            if high < rayOriginComponent || low > rayOriginComponent {
                return .goToPreviousSector
            }

            return .noneFound
        }

        var minT = (low - rayOriginComponent)/rayDirectionComponent
        var maxT = (high - rayOriginComponent)/rayDirectionComponent

        if (minT > maxT) {
            (minT, maxT) = (maxT, minT)
        }

        // If the range of the new t values is outside the bounding box,
        // then we need to consider the previous sector.
        if (minT > t2) || (maxT < t1) {
            return .goToPreviousSector
        }

        // If the lesser of the newly computed t values is larger than the
        // previously computed t, then we need to consider the previous sector.
        if let t = currentT, minT > t {
            return .goToPreviousSector
        }

        // If we computed a range of potential t values while examining the
        // previous coordinate, _and_ that range does not overlap the range of
        // t values for the current coordinate, then we need to return to the
        // previous uv sector.
        for previousTRange in previousTRanges {
            if let (previousMinT, previousMaxT) = previousTRange {
                if (minT > previousMaxT) || (maxT < previousMinT) {
                    return .goToPreviousSector
                }
            }
        }

        return .value(minT, maxT)
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

        // uvSectors is effectively a stack, used in the main loop below
        // to track which parts of the (u, v) space have searched for
        // intersections.
        let firstSector = Sector(lowUV: (self.uRange.0, self.vRange.0), highUV: (self.uRange.1, self.vRange.1))
        var uvSectors = [firstSector]
        uvSectors.reserveCapacity(32)

        var t: Double? = nil
        var uv: UV = .none

        // This loop treats uvSectors as a stack, the top of which the loop below
        // always operates. Each iteration examines the current sector, bounded by
        // the low and high values for u and v. Generally speaking, we compute
        // ranges of t values first for x, then for y, and then finally for z, and if all three
        // ranges overlap, _and_ the width of the "cube" formed by the ranges of values for t, u, and v
        // is less than the desired accuracy, then we capture the values for t, u, and v.
        // We then continue refining t, u, and v, or searching for such a tuple,
        // until the stack is empty.
        //
        // Note that each time we capture a value for t, it is always smaller than the previous
        // one captured. It is that final set of values of t, u, and v that represents an intersection.
        // The assumption is once the stack is empty, we have either found the closest intersection _or_
        // we have sufficiently and exhaustively searched (t,u,v) space for one and failed.
        //
        // TODO: Explain how we are guaranteed to exit this loop, and how we are
        // sure that the computed t value is provably the closest possible to the camera
        while let currentSector = uvSectors.popLast() {
            let lowUV  = currentSector.lowUV
            let highUV = currentSector.highUV

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
            // first based on the range of values for the x coordinate.
            switch computeTRangeForCoordinate(fn: self.fx,
                                              rayComponents: (localRay.origin.x, localRay.direction.x),
                                              sector: currentSector,
                                              currentT: t,
                                              boundingBoxTRange: (t1, t2),
                                              previousTRanges: []) {
            case .goToPreviousSector:
                continue
            case .noneFound:
                break
            case .value(let minT, let maxT):
                potentialT = minT
                rangeTForX = (minT, maxT)
                deltaT = maxT - minT
            }

            // Continue narrowing down t based on the range of values
            // for the y coordinate.
            switch computeTRangeForCoordinate(fn: self.fy,
                                              rayComponents: (localRay.origin.y, localRay.direction.y),
                                              sector: currentSector,
                                              currentT: t,
                                              boundingBoxTRange: (t1, t2),
                                              previousTRanges: [rangeTForX]) {
            case .goToPreviousSector:
                continue
            case .noneFound:
                break
            case .value(let minT, let maxT):
                potentialT = minT
                rangeTForY = (minT, maxT)
                let temp = maxT - minT
                if temp > deltaT {
                    deltaT = temp
                }
            }

            // Finally, continue narrowing down t based on the range
            // of values for the z coordinate
            switch computeTRangeForCoordinate(fn: self.fz,
                                              rayComponents: (localRay.origin.z, localRay.direction.z),
                                              sector: currentSector,
                                              currentT: t,
                                              boundingBoxTRange: (t1, t2),
                                              previousTRanges: [rangeTForX, rangeTForY]) {
            case .goToPreviousSector:
                continue
            case .noneFound:
                break
            case .value(let minT, let maxT):
                potentialT = minT
                let temp = maxT - minT
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
                    t = potentialT
                    uv = .value(lowUV.0, lowUV.1)
                }

                // OBSERVATION: uvSectors appears to never be empty in this block, and thus
                // the loop never immediately terminates right after this statement.
                continue
            }

            // If we got here, then we need to refine the values of u or v.
            // We do this by pushing a modified version of the sector
            // we just examined, as well as a brand new one.
            var previouslyExaminedSector = currentSector
            var newSector = currentSector

            // Here we determine which of the u and v parameters whose range
            // we're going to "split" for the next iteration of the loop.
            // Note that we're always going to choose the one whose range is
            // the larger.
            switch deltaU > deltaV {
            case true:
                // Take the average of the low and high values of u and
                // shrink the range of u for the brand new sector by lowering
                // its high u value, and shrink the range of the previous sector
                // by raising its low u value.
                let newU = (currentSector.lowUV.0 + currentSector.highUV.0)/2.0
                previouslyExaminedSector.lowUV.0 = newU
                newSector.highUV.0 = newU
            case false:
                // Do the same as above but instead for the v values of the new
                // and previous sectors.
                let newV = (currentSector.lowUV.1 + currentSector.highUV.1)/2.0
                previouslyExaminedSector.lowUV.1 = newV
                newSector.highUV.1 = newV
            }

            uvSectors.append(previouslyExaminedSector)
            uvSectors.append(newSector)
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

            return gradFv.cross(gradFu).normalize()
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
