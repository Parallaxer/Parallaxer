extension Float: Parallaxable {
    
    public static func progress(forValue value: Float, from: Float, to: Float) -> Double {
        return Double((value - from) / (to - from))
    }
    
    public static func value(forProgress progress: Double, from: Float, to: Float) -> Float {
        let progress = Float(progress)
        return from * (1 - progress) + to * progress
    }
}
