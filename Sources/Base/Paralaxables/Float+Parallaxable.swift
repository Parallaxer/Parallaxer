extension Float: Parallaxable {
    
    public static func position(forValue value: Float, from: Float, to: Float) -> Double {
        return Double((value - from) / (to - from))
    }
    
    public static func value(atPosition position: Double, from: Float, to: Float) -> Float {
        let position = Float(position)
        return from * (1 - position) + to * position
    }
}
