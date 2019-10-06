extension Float: Parallaxable {
    
    public static func unitPosition(
        forValue value: Float,
        from: Float,
        to: Float)
        -> Double
    {
        return Double((value - from) / (to - from))
    }
    
    public static func value(
        atUnitPosition unitPosition: Double,
        from: Float,
        to: Float)
        -> Float
    {
        let unitPosition = Float(unitPosition)
        return from * (1 - unitPosition) + to * unitPosition
    }
}
