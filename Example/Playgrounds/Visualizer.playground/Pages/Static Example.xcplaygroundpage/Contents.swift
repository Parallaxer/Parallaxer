import PlaygroundSupport
import Parallaxer
import RxSwift

// MARK: Static visualization example.

let visualizer = ParallaxView(frame: CGRect(x: 0, y: 0, width: 600, height: 600))

let parallax = Observable.just(7)
    .parallax(over: .interval(from: 0, to: 10), visualizer: visualizer)
    .parallaxRelate(to: .interval(from: -5, to: 15), visualizer: visualizer)
    .parallaxFocus(on: .interval(from: 0, to: 10), visualizer: visualizer)
    .parallaxMorph(with: .just(.clampToUnitInterval), visualizer: visualizer)
    .parallaxMorph(with: .just(.oscillate(numberOfTimes: 3)), visualizer: visualizer)

visualizer
