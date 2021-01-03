import Parallaxer
import RxSwift
import RxCocoa
import UIKit

extension ObservableType {
    
    public func parallax(
        over interval: Observable<ParallaxInterval<Element>>,
        visualizer: ParallaxView)
        -> Observable<ParallaxTransform<Element>>
        where Element: Parallaxable
    {
        let newTransform = parallax(over: interval)
        visualizer.visualize(newTransform.map { .started($0) })
        return newTransform
    }
    
    public func parallaxRelate<ValueType, ResultValueType>(
        to otherInterval: Observable<ParallaxInterval<ResultValueType>>,
        visualizer: ParallaxView)
        -> Observable<ParallaxTransform<ResultValueType>>
        where Element == ParallaxTransform<ValueType>
    {
        let newTransform = parallaxRelate(to: otherInterval)
        visualizer.visualize(newTransform.map { .related($0) })
        return newTransform
    }
    
    public func parallaxMorph<ValueType>(
        with curve: Observable<PositionCurve>,
        visualizer: ParallaxView)
        -> Observable<ParallaxTransform<ValueType>>
        where Element == ParallaxTransform<ValueType>
    {
        
        let newTransform = parallaxMorph(with: curve)
        let transformOperation = Observable
            .combineLatest(newTransform, curve)
            .map { transform, curve in
                return TransformOperation.morphed(transform, curve)
            }
        visualizer.visualize(transformOperation)
        return newTransform
    }

    public func parallaxFocus<ValueType>(
        on subinterval: Observable<ParallaxInterval<ValueType>>,
        visualizer: ParallaxView)
        -> Observable<ParallaxTransform<ValueType>>
        where Element == ParallaxTransform<ValueType>
    {
        let transformBefore = self
        let transformAfter = parallaxFocus(on: subinterval)
        let transformOperation = Observable
            .combineLatest(transformBefore, transformAfter)
            .map { transformBefore, transformAfter in
                return TransformOperation.focused(transformBefore, transformAfter)
            }
        visualizer.visualize(transformOperation)
        return transformAfter
    }
}
