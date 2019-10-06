import CoreGraphics

extension CGFloat: Parallaxable {
    
    public static func unitPosition(
        forValue value: CGFloat,
        from: CGFloat,
        to: CGFloat)
        -> Double
    {
        return Double((value - from) / (to - from))
    }
    
    public static func value(
        atUnitPosition unitPosition: Double,
        from: CGFloat,
        to: CGFloat)
        -> CGFloat
    {
        let unitPosition = CGFloat(unitPosition)
        return from * (1 - unitPosition) + to * unitPosition
    }
}
