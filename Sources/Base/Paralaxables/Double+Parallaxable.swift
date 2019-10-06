extension Double: Parallaxable {

    public static func unitPosition(
        forValue value: Double,
        from: Double,
        to: Double)
        -> Double
    {
        return (value - from) / (to - from)
    }
    
    public static func value(
        atUnitPosition unitPosition: Double,
        from: Double,
        to: Double)
        -> Double
    {
        return from * (1 - unitPosition) + to * unitPosition
    }
}
