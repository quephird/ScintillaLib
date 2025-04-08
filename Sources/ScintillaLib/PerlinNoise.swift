//
//  PerlinNoise.swift
//  ScintillaLib
//
//  Created by Danielle Kefford on 3/30/25.
//

import Foundation

struct PerlinNoise {
    private static var seedValues: [Int] = [
        151, 160, 137,  91,  90,  15, 131,  13, 201,  95,  96,  53, 194, 233,   7, 225,
        140,  36, 103,  30,  69, 142,   8,  99,  37, 240,  21,  10,  23, 190,   6, 148,
        247, 120, 234,  75,   0,  26, 197,  62,  94, 252, 219, 203, 117,  35,  11,  32,
         57, 177,  33,  88, 237, 149,  56,  87, 174,  20, 125, 136, 171, 168,  68, 175,
         74, 165,  71, 134, 139,  48,  27, 166,  77, 146, 158, 231,  83, 111, 229, 122,
         60, 211, 133, 230, 220, 105,  92,  41,  55,  46, 245,  40, 244, 102, 143,  54,
         65,  25,  63, 161,   1, 216,  80,  73, 209,  76, 132, 187, 208,  89,  18, 169,
        200, 196, 135, 130, 116, 188, 159,  86, 164, 100, 109, 198, 173, 186,   3,  64,
         52, 217, 226, 250, 124, 123,   5, 202,  38, 147, 118, 126, 255,  82,  85, 212,
        207, 206,  59, 227,  47,  16,  58,  17, 182, 189,  28,  42,  23, 183, 170, 213,
        119, 248, 152,   2,  44, 154, 163,  70, 221, 153, 101, 155, 167,  43, 172,   9,
        129,  22,  39, 253,  19,  98, 108, 110,  79, 113, 224, 232, 178, 185, 112, 104,
        218, 246,  97, 228, 251,  34, 242, 193, 238, 210, 144,  12, 191, 179, 162, 241,
         81,  51, 145, 235, 249,  14, 239, 107,  49, 192, 214,  31, 181, 199, 106, 157,
        184,  84, 204, 176, 115, 121,  50,  45, 127,   4, 150, 254, 138, 236, 205,  93,
        222, 114,  67,  29,  24,  72, 243, 141, 128, 195,  78,  66, 215,  61, 156, 180
    ]

    private var values: [Int] = Self.seedValues + Self.seedValues

    // Smoothing function that 1) has a second derivative such that
    // f''(0) == f''(1), which avoids discontinuities when using
    // this function to generate 3D terrains, and 2) itself has
    // range [0, 1] over the domain [0, 1].
    private func fade(t: Double) -> Double {
        return t * t * t * (t * (t * 6 - 15) + 10)
    }

    // Returns the value between a and b that is t times the distance
    // between them added to a, where t is a value in the range [0, 1].
    private func lerp(t: Double, a: Double, b: Double) -> Double {
        return a + t * (b - a)
    }

    // This function effectively takes the dot product of the vector defined
    // by (x, y, z) and one of twelve possible gradient vectors pseudorandomly
    // selected by the last four bits of the hash parameter. Those gradient vectors
    // are:
    //
    //     (1, 1, 0), (-1, 1, 0), (1, -1, 0), (-1, -1, 0),
    //     (1, 0, 1), (-1, 0, 1), (1, 0, -1), (-1, 0, -1),
    //     (0, 1, 1), (0, -1, 1), (0, 1, -1), (0, -1, -1)
    private func grad(hash: Int, x: Double, y: Double, z: Double) -> Double {
        let h = hash & 15

        let u = h < 8 ? x : y
        let v = h < 4 ? y : (h == 12 || h == 14 ? x : z)

        return ((h & 1) == 0 ? u : -u) + ((h & 2) == 0 ? v : -v)
    }

    public func noise(x: Double, y: Double, z: Double) -> Double {
        // Map last eight bits of input x, y, and z values to
        // a corner of a unit cube within one that is 256x256x256
        let cubeX = Int(floor(x)) & 255
        let cubeY = Int(floor(y)) & 255
        let cubeZ = Int(floor(z)) & 255

        // ... then assign "random" values to each of the eight corners of that cube
        let AAA = values[values[values[cubeX] + cubeY] + cubeZ]
        let AAB = values[values[values[cubeX] + cubeY] + cubeZ+1]
        let ABA = values[values[values[cubeX] + cubeY+1] + cubeZ]
        let ABB = values[values[values[cubeX] + cubeY+1] + cubeZ+1]
        let BAA = values[values[values[cubeX+1] + cubeY] + cubeZ]
        let BAB = values[values[values[cubeX+1] + cubeY] + cubeZ+1]
        let BBA = values[values[values[cubeX+1] + cubeY+1] + cubeZ]
        let BBB = values[values[values[cubeX+1] + cubeY+1] + cubeZ+1]

        // Get fractional part of x, y, z of point in cube
        let fractX = x - floor(x)
        let fractY = y - floor(y)
        let fractZ = z - floor(z)

        // ... then compute the interpolation values for those fractional values
        let u = fade(t: fractX)
        let v = fade(t: fractY)
        let w = fade(t: fractZ)

        // ... and then finally compute an average value for the set of eight points
        // by first averaging values for each of the four pairs of edges, then for the
        // two pairs of those values, then for the final pair.
        return lerp(t: w,
                    a: lerp(t: v,
                            a: lerp(t: u,
                                    a: grad(hash: AAA, x: fractX, y: fractY, z: fractZ),
                                    b: grad(hash: BAA, x: fractX-1, y: fractY, z: fractZ)),
                            b: lerp(t: u,
                                    a: grad(hash: ABA, x: fractX, y: fractY-1, z: fractZ),
                                    b: grad(hash: BBA, x: fractX-1, y: fractY-1, z: fractZ))),
                    b: lerp(t: v,
                            a: lerp(t: u,
                                    a: grad(hash: AAB, x: fractX, y: fractY, z: fractZ-1),
                                    b: grad(hash: BAB, x: fractX-1, y: fractY, z: fractZ-1)),
                            b: lerp(t: u,
                                    a: grad(hash: ABB, x: fractX, y: fractY-1, z: fractZ-1),
                                    b: grad(hash: BBB, x: fractX-1, y: fractY-1, z: fractZ-1))))
    }
}
