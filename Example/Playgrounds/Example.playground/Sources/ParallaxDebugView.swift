import Parallaxer
import RxSwift
import RxCocoa
import UIKit

public enum TransformOperation<ValueType: Parallaxable> {
    case started(ParallaxTransform<ValueType>)
    case related(ParallaxTransform<ValueType>)
    case morphed(ParallaxTransform<ValueType>, PositionCurve)
    case focused(ParallaxTransform<ValueType>)
}

final class ParallaxTransformView: UIView {
    
    private struct Constants {
        static let cursorSize = CGSize(width: 5, height: 40)
        static let cursorColor = UIColor.blue
        static let boundarySize = CGSize(width: 20, height: 40)
        static let boundaryColor = UIColor.red
        static let rulerHeight = CGFloat(2)
        static let rulerColor = UIColor.gray
    }
    
    private let rulerView: UIView = {
        let rulerView = UIView()
        rulerView.backgroundColor = Constants.rulerColor
        rulerView.translatesAutoresizingMaskIntoConstraints = false
        rulerView.heightAnchor.constraint(equalToConstant: Constants.rulerHeight).isActive = true
        return rulerView
    }()
    
    private let cursorView: UIView = {
        let cursorView = UIView()
        cursorView.translatesAutoresizingMaskIntoConstraints = false
        cursorView.widthAnchor.constraint(equalToConstant: Constants.cursorSize.width).isActive = true
        cursorView.heightAnchor.constraint(equalToConstant: Constants.cursorSize.height).isActive = true
        cursorView.backgroundColor = Constants.cursorColor
        return cursorView
    }()
    
    private var cursorConstraint: NSLayoutConstraint!
    
    private var boundsObservable: Observable<CGRect> {
        return rx.observe(CGRect.self, #keyPath(UIView.bounds))
            .map { optionalBounds in return optionalBounds! }
    }
    
    private var boundsInterval: Observable<ParallaxInterval<CGFloat>> {
        return boundsObservable
            .map { bounds in
                return try ParallaxInterval(from: 0, to: bounds.maxX)
            }
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.infinite)
        
        heightAnchor.constraint(equalToConstant: Constants.cursorSize.height).isActive = true
        
        addSubview(rulerView)
        rulerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        rulerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        rulerView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(cursorView)
        cursorView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        cursorConstraint = cursorView.centerXAnchor.constraint(greaterThanOrEqualTo: leadingAnchor)
        cursorConstraint.isActive = true
        cursorView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindTransformOperation(
        _ operation: Observable<TransformOperation<CGFloat>>)
        -> Disposable
    {
        let operation = operation.share()
    
        let normalizedTransform = operation
            .map { operation -> ParallaxTransform<CGFloat> in
                switch operation {

                case .started(let transform),
                     .related(let transform),
                     .morphed(let transform, _),
                     .focused(let transform):
                    return transform
                }
            }
            .parallaxRelate(to: .interval(from: 0, to: Double(1)))
        
        
        return Disposables.create([
            self.bindCursorPosition(normalizedTransform)
        ])
    }
    
    func bindCursorPosition(_ normalizedTransform: Observable<ParallaxTransform<Double>>) -> Disposable {
        let halfCursorWidth = Constants.cursorSize.width / 2

        let cursorInterval = boundsInterval
            .map { boundsInterval in
                return try ParallaxInterval(
                    from: boundsInterval.from + halfCursorWidth,
                    to: boundsInterval.to - halfCursorWidth)
            }
        
        return normalizedTransform
            .parallaxRelate(to: cursorInterval)
            .parallaxValue()
            .bind(to: cursorConstraint.rx.constant)
    }
    
    private static func makeIntervalBoundaryView() -> UIView {
        let boundaryView = UIView()
        boundaryView.translatesAutoresizingMaskIntoConstraints = false
        boundaryView.widthAnchor.constraint(equalToConstant: Constants.boundarySize.width).isActive = true
        boundaryView.heightAnchor.constraint(equalToConstant: Constants.boundarySize.height).isActive = true
        boundaryView.backgroundColor = Constants.boundaryColor
        return boundaryView
    }
}

public final class ParallaxDebugView: UIView {
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private var operations = [TransformOperation<CGFloat>]()
    private var operationIndicesByName = [String: Int]()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func bindTransformOperation<ValueType: Parallaxable>(
        _ operation: Observable<TransformOperation<ValueType>>)
        -> Disposable
    {
        let normalizedOperation = operation
            .map(ParallaxDebugView.normalize)
        
        let name = operation
            .map { operation -> String in
                switch operation {
                
                case .started(let transform):
                    return "parallax: \(transform.interval)\nPosition: \(transform.position)"
                case .related(let transform):
                    return "relate: \(transform.interval)\nPosition: \(transform.position)"
                case .morphed(let transform, let curve):
                    return "morph: \(curve)\nPosition: \(transform.position)"
                case .focused(let transform):
                    return "focus: \(transform.interval)\nPosition: \(transform.position)"
                }
            }
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textColor = .blue
        nameLabel.numberOfLines = 3
        nameLabel.font = .monospacedSystemFont(ofSize: 16, weight: .semibold)
        
        let transformView = ParallaxTransformView()
        
        let transformStackView = UIStackView(arrangedSubviews: [nameLabel, transformView])
        transformStackView.axis = .vertical
        transformStackView.spacing = 6
        stackView.distribution = .equalSpacing

        stackView.addArrangedSubview(transformStackView)
    
        return Disposables.create([
            transformView.bindTransformOperation(normalizedOperation),
            name.bind(to: nameLabel.rx.text)
        ])
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
        case .morphed(let transform, let curve):
            let normalizedTransform = normalize(transform)
            return .morphed(normalizedTransform, curve)
        case .focused(let transform):
            let normalizedTransform = normalize(transform)
            return .focused(normalizedTransform)
        }
    }
}
