import CoreGraphics

extension CGFloat: Parallaxable {
    
    public static func progress(forValue value: CGFloat, from: CGFloat, to: CGFloat) -> Double {
        return Double((value - from) / (to - from))
    }
    
    public static func value(forProgress progress: Double, from: CGFloat, to: CGFloat) -> CGFloat {
        let progress = CGFloat(progress)
        return from * (1 - progress) + to * progress
    }
}
