/// A bidirectional interval which specifies a boundary such that `from` != `to`.
public struct ParallaxInterval<ValueType: Parallaxable> {
    
    private let from: ValueType
    private let to: ValueType

    /// Initialize a `ParallaxInterval`, which defines a bidirectional interval.
    ///
    /// - Warning: ⚠️ Single value intervals, where `from` and `to` are equal, are not supported and shall
    /// result in a `nil` interval.
    ///
    /// - Parameters:
    ///   - from:   The start of the interval.
    ///   - to:     The end of the interval.
    /// - Returns: A parallax interval, which may be used with parallax transformations. `nil` if `from` and
    /// `to` are the same.
    public init?(from: ValueType,
                 to: ValueType)
    {
        guard from != to else {
            return nil
        }
        
        self.from = from
        self.to = to
    }
    
    func position(
        forValue value: ValueType)
        -> Double
    {
        return ValueType.unitPosition(forValue: value, from: from, to: to)
    }
    
    func value(
        atPosition position: Double)
        -> ValueType
    {
        return ValueType.value(atUnitPosition: position, from: from, to: to)
    }
}
