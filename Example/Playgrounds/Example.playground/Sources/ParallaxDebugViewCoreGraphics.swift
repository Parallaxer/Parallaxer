import CoreGraphics
import Parallaxer
import RxSwift
import RxCocoa
import UIKit

public final class ParallaxDebugViewCoreGraphics: UIView {
    
    public enum TransformOperation<ValueType:Parallaxable> {
        case started(ParallaxTransform<ValueType>)
        case related(ParallaxTransform<ValueType>)
        case morphed(ParallaxTransform<ValueType>)
        case focused(ParallaxTransform<ValueType>)
    }
        
    private var operations = [TransformOperation<CGFloat>]()
    private var operationIndicesByName = [String: Int]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .yellow
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func draw(_ rect: CGRect) {
        // Get the Graphics Context
         if let context = UIGraphicsGetCurrentContext() {
            
            let normalLineWidth = CGFloat(3)
            let normalLineColor = UIColor.black
            
            let userLineColor = UIColor.green

            let cellHeight = CGFloat(20)
            let halfCellHeight = cellHeight / 2
            let emptySpace = CGFloat(40)

            for operation in operations.enumerated() {
                let intervalStartPoint = CGPoint(
                    x: rect.minX + halfCellHeight,
                    y: rect.minY + halfCellHeight + ((cellHeight + emptySpace) * CGFloat(operation.offset)))
            
                let intervalEndPoint = CGPoint(
                    x: rect.maxX - halfCellHeight,
                    y: intervalStartPoint.y)
                
                guard let drawInterval = try? ParallaxInterval(
                        from: intervalStartPoint.x,
                        to: intervalEndPoint.x) else
                {
                    continue
                }
                
                switch operation.element {
                
                case .started(let transform),
                     .related(let transform),
                     .morphed(let transform):
                    
                    // Draw timeline.
                    context.setLineWidth(normalLineWidth)
                    context.setFillColor(normalLineColor.cgColor)
                    context.move(to: intervalStartPoint)
                    context.addLine(to: intervalEndPoint)
                    context.strokePath()
                    
                    // Draw endpoints.
                    context.setLineWidth(normalLineWidth)
                    context.setFillColor(normalLineColor.cgColor)
                    context.setStrokeColor(normalLineColor.cgColor)
                    context.addArc(
                        center: intervalStartPoint,
                        radius: halfCellHeight,
                        startAngle: 0,
                        endAngle: 2 * .pi,
                        clockwise: true)
                    context.fillPath()

                    context.addArc(
                        center: intervalEndPoint,
                        radius: halfCellHeight,
                        startAngle: 0,
                        endAngle: 2 * .pi,
                        clockwise: true)
                    context.fillPath()

                    // Draw current position hash mark.
                    let drawInterval = transform.relate(to: drawInterval)
                    let currentValue = drawInterval.parallaxValue()
                    let hashStartPoint = CGPoint(x: currentValue, y: intervalStartPoint.y - halfCellHeight)
                    let hashEndPoint = CGPoint(x: currentValue, y: intervalStartPoint.y + cellHeight)
                    
                    context.setLineWidth(normalLineWidth)
                    context.setFillColor(userLineColor.cgColor)
                    context.move(to: hashStartPoint)
                    context.addLine(to: hashEndPoint)
                    context.strokePath()
                    
                case .focused(let transform):
                    break
                }
            }
         }
    }
    
    public func add<ValueType: Parallaxable>(
        operation: TransformOperation<ValueType>,
        name: String)
    {
        let normalizedOperation = ParallaxDebugViewCoreGraphics.normalize(operation)
        if let index = operationIndicesByName[name] {
            operations[index] = normalizedOperation
        } else {
            let index = operations.count
            operations.append(normalizedOperation)
            operationIndicesByName[name] = index
        }

        setNeedsDisplay()
    }
    
    private static func normalize<ValueType: Parallaxable>(
        _ operation: TransformOperation<ValueType>)
        -> TransformOperation<CGFloat>
    {
        let normalize = { (transform: ParallaxTransform<ValueType>) -> ParallaxTransform<CGFloat> in
            let normalizationInterval = try! ParallaxInterval(from: CGFloat(0), to: 1)
            return transform.relate(to: normalizationInterval)
        }
        
        switch operation {
        
        case .started(let transform):
            let normalizedTransform = normalize(transform)
            return .started(normalizedTransform)
        case .related(let transform):
            let normalizedTransform = normalize(transform)
            return .related(normalizedTransform)
        case .morphed(let transform):
            let normalizedTransform = normalize(transform)
            return .morphed(normalizedTransform)
        case .focused(let transform):
            let normalizedTransform = normalize(transform)
            return .focused(normalizedTransform)
        }
    }
}
