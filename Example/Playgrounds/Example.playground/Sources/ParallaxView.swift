import Parallaxer
import RxSwift
import RxCocoa
import UIKit

public enum TransformOperation<ValueType: Parallaxable> {
    case started(ParallaxTransform<ValueType>)
    case related(ParallaxTransform<ValueType>)
    case morphed(ParallaxTransform<ValueType>, PositionCurve)
    case focused(ParallaxTransform<ValueType>, ParallaxTransform<ValueType>) // before transform, after transform.
}

/// Renders parallax operations.
public final class ParallaxView: UIView {
    
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
    
    private let disposeBag = DisposeBag()
    
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
    
    public func visualize<ValueType: Parallaxable>(
        _ operation: Observable<TransformOperation<ValueType>>)
    {
        let title = operation
            .map { operation -> String in
                let formatPosition = { (position: Double) -> String in
                    let positionInterval = try! ParallaxInterval(from: 0, to: 1)
                    let positionTransform = ParallaxTransform(
                        interval: positionInterval,
                        parallaxValue: position)
                    let percentageInterval = try! ParallaxInterval(from: 0, to: 100)
                    let percentageValue = positionTransform
                        .relate(to: percentageInterval)
                        .parallaxValue()
                    return "\(Int(percentageValue))%"
                }
                switch operation {
                
                case .started(let transform):
                    return "parallax: \(transform.interval)\nPosition: \(formatPosition(transform.position))"
                case .related(let transform):
                    return "relate: \(transform.interval)\nPosition: \(formatPosition(transform.position))"
                case .morphed(let transform, let curve):
                    return "morph: \(curve)\nPosition: \(formatPosition(transform.position))"
                case .focused(_, let transform):
                    return "focus: \(transform.interval)\nPosition: \(formatPosition(transform.position))"
                }
            }
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .blue
        titleLabel.numberOfLines = 3
        titleLabel.font = .monospacedSystemFont(ofSize: 16, weight: .semibold)
        
        let transformView = ParallaxTransformView()
        
        let transformStackView = UIStackView(arrangedSubviews: [titleLabel, transformView])
        transformStackView.axis = .vertical
        transformStackView.spacing = 6
        stackView.distribution = .equalSpacing

        stackView.addArrangedSubview(transformStackView)
        
        transformView
            .bindTransformOperation(operation)
            .disposed(by: disposeBag)
        
        title
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
    }
}

/// Internal class for rending a single transform.
final class ParallaxTransformView: UIView {
    
    private struct Constants {
        static let cursorSize = CGSize(width: 5, height: 20)
        static let cursorColor = UIColor.blue
        static let cursorOutOfBoundsColor = UIColor.red
        static let boundarySize = CGSize(width: 20, height: 20)
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
    
    private let cursorLabel: UILabel = {
        let cursorLabel = UILabel()
        cursorLabel.translatesAutoresizingMaskIntoConstraints = false
        cursorLabel.textColor = .blue
        cursorLabel.numberOfLines = 1
        cursorLabel.font = .monospacedSystemFont(ofSize: 10, weight: .light)
        return cursorLabel
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
        
        let rulerContainerView = UIView()
        rulerContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(rulerContainerView)
        rulerContainerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        rulerContainerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        rulerContainerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
                
        rulerContainerView.addSubview(rulerView)
        rulerView.leadingAnchor.constraint(equalTo: rulerContainerView.leadingAnchor).isActive = true
        rulerView.trailingAnchor.constraint(equalTo: rulerContainerView.trailingAnchor).isActive = true
        rulerView.centerYAnchor.constraint(equalTo: rulerContainerView.centerYAnchor).isActive = true
        
        rulerContainerView.addSubview(cursorView)
        cursorView.topAnchor.constraint(equalTo: rulerContainerView.topAnchor).isActive = true
        cursorConstraint = cursorView.centerXAnchor.constraint(equalTo: rulerContainerView.leadingAnchor)
        cursorConstraint.priority = .defaultHigh
        cursorConstraint.isActive = true
        cursorView.leadingAnchor.constraint(greaterThanOrEqualTo: rulerContainerView.leadingAnchor).isActive = true
        cursorView.trailingAnchor.constraint(lessThanOrEqualTo: rulerContainerView.trailingAnchor).isActive = true
        cursorView.bottomAnchor.constraint(equalTo: rulerContainerView.bottomAnchor).isActive = true

        addSubview(cursorLabel)
        cursorLabel.topAnchor.constraint(equalTo: rulerContainerView.bottomAnchor).isActive = true
        let cursorCenterX = cursorLabel.centerXAnchor.constraint(equalTo: cursorView.centerXAnchor)
        cursorCenterX.priority = .defaultLow
        cursorCenterX.isActive = true
        cursorLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor).isActive = true
        cursorLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor).isActive = true
        cursorLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindTransformOperation<ValueType: Parallaxable>(
        _ operation: Observable<TransformOperation<ValueType>>)
        -> Disposable
    {
        let operation = operation.share()
    
        let transform = operation
            .map { operation -> ParallaxTransform<ValueType> in
                switch operation {

                case .started(let transform),
                     .related(let transform),
                     .morphed(let transform, _),
                     .focused(_, let transform):
                    return transform
                }
            }
        
        return Disposables.create([
            self.bindCursorPosition(transform)
        ])
    }
    
    private func bindCursorPosition<ValueType: Parallaxable>(
        _ transform: Observable<ParallaxTransform<ValueType>>)
        -> Disposable
    {
        let transform = transform.share()
        
        let halfCursorWidth = Constants.cursorSize.width / 2
        let cursorInterval = boundsInterval
            .map { boundsInterval in
                return try ParallaxInterval(
                    from: boundsInterval.from + halfCursorWidth,
                    to: boundsInterval.to - halfCursorWidth)
            }
        
        let cursorConstraintConstant = transform
            .do(onNext: { [weak self] transform in
                guard let self = self else {
                    return
                }
                
                // Change cursor color when it goes out of bounds.
                if transform.position < 0 || transform.position > 1 {
                    self.cursorView.backgroundColor = Constants.cursorOutOfBoundsColor
                    self.cursorLabel.textColor = Constants.cursorOutOfBoundsColor
                } else {
                    self.cursorView.backgroundColor = Constants.cursorColor
                    self.cursorLabel.textColor = Constants.cursorColor
                }
            })
            .parallaxRelate(to: cursorInterval)
            .parallaxMorph(with: .just(.clampToUnitInterval))
            .parallaxValue()
        
        let currentValue = transform
            .parallaxValue()
            .map { return "\($0)"}

        return Disposables.create([
            cursorConstraintConstant.bind(to: cursorConstraint.rx.constant),
            currentValue.bind(to: cursorLabel.rx.text)
        ])
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
