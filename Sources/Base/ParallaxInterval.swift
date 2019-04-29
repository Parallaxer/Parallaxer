/// A `ParallaxInterval` specifies a bidirectional interval with boundaries such that `from != to`.
public struct ParallaxInterval<ValueType: Parallaxable> {
    
    private let from: ValueType
    private let to: ValueType

    /// Initialize a `ParallaxInterval`, which defines a bidirectional interval.
    ///
    /// - note: `from` and `to` mustn't equal.
    ///
    /// - Parameters:
    ///   - from:   The start of the interval.
    ///   - to:     The end of the interval.
    public init(from: ValueType, to: ValueType) {
        guard from != to else {
            fatalError("A ParallaxInterval's boundaries mustn't equal.")
        }
        
        self.from = from
        self.to = to
    }
    
    func position(forValue value: ValueType) -> Double {
        return ValueType.position(forValue: value, from: from, to: to)
    }
    
    func value(atPosition position: Double) -> ValueType {
        return ValueType.value(atPosition: position, from: from, to: to)
    }
}

extension ParallaxInterval: Equatable {
    
    public static func ==(lhs: ParallaxInterval<ValueType>, rhs: ParallaxInterval<ValueType>) -> Bool {
        return lhs.from == rhs.from && lhs.to == rhs.to
    }
}

extension ParallaxInterval: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(from)
        hasher.combine(to)
    }
}
