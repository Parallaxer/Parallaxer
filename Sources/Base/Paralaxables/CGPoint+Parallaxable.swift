import CoreGraphics

extension CGPoint: Parallaxable {
    
    public static func unitPosition(forValue value: CGPoint, from: CGPoint, to: CGPoint) -> Double {
        let a = CGPoint(x: value.x - from.x, y: value.y - from.y)
        let b = CGPoint(x: to.x - from.x, y: to.y - from.y)
        let bmag = CGFloat(sqrt(Double(b.x * b.x + b.y * b.y)))
        let bnorm = CGPoint(x: b.x / bmag, y: b.y / bmag)
        let scalarProjection = a.x * bnorm.x + a.y * bnorm.y
        return Double(scalarProjection / bmag)
    }
    
    public static func value(atUnitPosition position: Double, from: CGPoint, to: CGPoint) -> CGPoint {
        let position = CGFloat(position)
        let b = CGPoint(x: to.x - from.x, y: to.y - from.y)
        return CGPoint(x: from.x + b.x * position, y: from.y + b.y * position)
    }
}

extension CGPoint: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}
