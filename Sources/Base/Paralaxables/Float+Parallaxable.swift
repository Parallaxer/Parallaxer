extension Float: Parallaxable {
    
    public static func unitPosition(forValue value: Float, from: Float, to: Float) -> Double {
        return Double((value - from) / (to - from))
    }
    
    public static func value(atUnitPosition position: Double, from: Float, to: Float) -> Float {
        let position = Float(position)
        return from * (1 - position) + to * position
    }
}
