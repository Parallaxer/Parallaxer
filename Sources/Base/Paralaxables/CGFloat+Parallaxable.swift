import CoreGraphics

extension CGFloat: Parallaxable {
    
    public static func position(forValue value: CGFloat, from: CGFloat, to: CGFloat) -> Double {
        return Double((value - from) / (to - from))
    }
    
    public static func value(atPosition position: Double, from: CGFloat, to: CGFloat) -> CGFloat {
        let position = CGFloat(position)
        return from * (1 - position) + to * position
    }
}
