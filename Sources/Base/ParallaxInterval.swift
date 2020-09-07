/// A bidirectional interval which specifies a boundary such that `from` != `to`.
public struct ParallaxInterval<ValueType: Parallaxable>: Equatable {

    /// The first value contained within the interval.
    public let from: ValueType

    /// The last value contained within the interval.
    public let to: ValueType

    /// Initialize a `ParallaxInterval`, which defines a bidirectional interval.
    ///
    /// - Warning: ⚠️ Single value intervals, where `from` and `to` are equal, are not supported and shall
    /// result in a `nil` interval.
    ///
    /// - Parameters:
    ///   - from:   The start of the interval.
    ///   - to:     The end of the interval.
    /// - Returns: A parallax interval.. `nil` if `from` and `to` are the same.
    public init?(from: ValueType, to: ValueType) {
        guard from != to else {
            return nil
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

extension ParallaxInterval: CustomStringConvertible {

    public var description: String {
        return "ParallaxInterval<\(String(describing: ValueType.self))>(from: \(from), to: \(to))"
    }
}
