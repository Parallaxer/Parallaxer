extension Double: Parallaxable {

    public static func progress(forValue value: Double, from: Double, to: Double) -> Double {
        return (value - from) / (to - from)
    }
    
    public static func value(forProgress progress: Double, from: Double, to: Double) -> Double {
        return from * (1 - progress) + to * progress
    }
}
