/**
 A `ParallaxInterval` specifies a bidirectional interval with boundaries such that `from != to`.
 */
public struct ParallaxInterval<ValueType: Parallaxable> {
    
    fileprivate let from: ValueType
    fileprivate let to: ValueType

    /**
     Initialize a `ParallaxInterval`, which defines a bidirectional interval.
     
     - note: `from` and `to` mustn't equal.
     
     - parameter from:  The start of the interval.
     - parameter to:    The end of the interval.
     */
    public init(from: ValueType, to: ValueType) {
        assert(from != to, "A ParallaxInterval's boundaries mustn't equal.")
        self.from = from
        self.to = to
    }
    
    func progress(forValue value: ValueType) -> Double {
        return ValueType.progress(forValue: value, from: self.from, to: self.to)
    }
    
    func value(forProgress progress: Double) -> ValueType {
        return ValueType.value(forProgress: progress, from: self.from, to: self.to)
    }
}

extension ParallaxInterval: Hashable {
    
    public var hashValue: Int {
        return self.from.hashValue << MemoryLayout<ValueType>.size ^ self.to.hashValue
    }
}

public func ==<ValueType: Parallaxable>(lhs: ParallaxInterval<ValueType>, rhs: ParallaxInterval<ValueType>)
    -> Bool
{
    return lhs.from == rhs.from && lhs.to == rhs.to
}
