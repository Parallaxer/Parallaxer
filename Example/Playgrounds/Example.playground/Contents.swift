//: A UIKit based Playground for presenting user interface
  
import PlaygroundSupport
import Parallaxer
import RxSwift
import RxCocoa
import UIKit

extension ObservableType {
    
    public func parallax(
        over interval: Observable<ParallaxInterval<Element>>,
        visualizer: ParallaxDebugView)
        -> Observable<ParallaxTransform<Element>>
        where Element: Parallaxable
    {
        let newTransform = parallax(over: interval)
        visualizer.bindTransformOperation(newTransform.map { .started($0) })
        return newTransform
    }
    
    public func parallaxRelate<ValueType, ResultValueType>(
        to otherInterval: Observable<ParallaxInterval<ResultValueType>>,
        visualizer: ParallaxDebugView)
        -> Observable<ParallaxTransform<ResultValueType>>
        where Element == ParallaxTransform<ValueType>
    {
        let newTransform = parallaxRelate(to: otherInterval)
        visualizer.bindTransformOperation(newTransform.map { .related($0) })
        return newTransform
    }
    
    public func parallaxMorph<ValueType>(
        with curve: Observable<PositionCurve>,
        visualizer: ParallaxDebugView)
        -> Observable<ParallaxTransform<ValueType>>
        where Element == ParallaxTransform<ValueType>
    {
        
        let newTransform = parallaxMorph(with: curve)
        let visualized = Observable
            .combineLatest(newTransform, curve)
            .map { transform, curve in
                return TransformOperation.morphed(transform, curve)
            }
        visualizer.bindTransformOperation(visualized)
        return newTransform
    }

    public func parallaxFocus<ValueType>(
        subinterval: Observable<ParallaxInterval<ValueType>>,
        visualizer: ParallaxDebugView)
        -> Observable<ParallaxTransform<ValueType>>
        where Element == ParallaxTransform<ValueType>
    {
        let transformBefore = self
        let transformAfter = parallaxFocus(subinterval: subinterval)
        let visualized = Observable
            .combineLatest(transformBefore, transformAfter)
            .map { transformBefore, transformAfter in
                return TransformOperation.focused(transformBefore, transformAfter)
            }
        visualizer.bindTransformOperation(visualized)
        return transformAfter
    }
}

class MyViewController : UIViewController {
    
    private lazy var cursorView: UIView = {
        let cursorView = UIView()
        cursorView.translatesAutoresizingMaskIntoConstraints = false
        cursorView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        cursorView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        cursorView.backgroundColor = UIColor.blue
        cursorView.alpha = 0
        return cursorView
    }()
    
    private lazy var slider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.isContinuous = true
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.backgroundColor = .blue
        return slider
    }()
    
    private lazy var debugView: ParallaxDebugView = {
        let debugView = ParallaxDebugView()
        debugView.translatesAutoresizingMaskIntoConstraints = false
        return debugView
    }()
    
    private var cursorConstraint: NSLayoutConstraint!
    
    private let disposeBag = DisposeBag()
    
    private let backgroundScheduler = SerialDispatchQueueScheduler(qos: .userInteractive)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(slider)
        slider.heightAnchor.constraint(equalToConstant: 40).isActive = true
        slider.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        slider.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        slider.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        view.addSubview(debugView)
        debugView.topAnchor.constraint(equalTo: slider.bottomAnchor).isActive = true
        debugView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        debugView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        view.addSubview(cursorView)
        cursorView.topAnchor.constraint(equalTo: debugView.bottomAnchor).isActive = true
        cursorConstraint = cursorView.centerXAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor)
        cursorConstraint.isActive = true
        cursorView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        observeTestTransform()
    }
    
    func observeTestTransform() {
        let parallax = slider.rx.value
            .parallax(over: .interval(from: slider.minimumValue, to: slider.maximumValue), visualizer: debugView)
            .parallaxRelate(to: .interval(from: -5, to: 15), visualizer: debugView)
            .parallaxFocus(subinterval: .interval(from: 0, to: 10), visualizer: debugView)
            .parallaxMorph(with: .just(.clampToUnitInterval), visualizer: debugView)
            .parallaxMorph(with: .just(.oscillate(numberOfTimes: 3)), visualizer: debugView)
            
        parallax
            .parallaxRelate(to: .interval(from: 10, to: 400 - 10))
            .parallaxValue()
            .bind(to: cursorConstraint.rx.constant)
            .disposed(by: disposeBag)
    }
}
// Present the view controller in the Live View window
let viewController = MyViewController()
viewController.view.frame = .init(x: 0, y: 0, width: 400, height: 800)
PlaygroundPage.current.liveView = viewController
