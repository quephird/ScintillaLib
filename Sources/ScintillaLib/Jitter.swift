//
//  Jitter.swift
//  
//
//  Created by Danielle Kefford on 10/11/22.
//

extension Array {
    func cycle() -> UnfoldSequence<Element, Int> {
        return sequence(state: 0) { state in
            let nextValue = self[state]
            state = (state+1) % self.count
            return nextValue
        }
    }
}

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
