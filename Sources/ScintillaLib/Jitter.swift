//
//  Jitter.swift
//  
//
//  Created by Danielle Kefford on 10/11/22.
//

public protocol Jitter {
    mutating func next() -> Double
}

public struct NoJitter: Jitter {
    public mutating func next() -> Double {
        return 0.5
    }
}

public struct PseudorandomJitter: Jitter {
    var index: Int = 0
    var values: [Double]

    public init(_ values: [Double]) {
        self.values = values
    }

    public mutating func next() -> Double {
        let nextValue = self.values[index]
        index = (index+1) % self.values.count
        return nextValue
    }
}

public struct RandomJitter: Jitter {
    public func next() -> Double {
        return Double.random(in: 0.0...1.0)
    }
}
