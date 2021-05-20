import PlaygroundSupport
import Parallaxer
import RxSwift

// MARK: Interactive visualization example. (Make sure the "live view" is visible in the editor.)

let interactiveView = InteractiveParallaxView(frame: CGRect(x: 0, y: 0, width: 500, height: 600))

let sliderInterval = Observable<ParallaxInterval<Float>>.interval(
    from: interactiveView.slider.minimumValue,
    to: interactiveView.slider.maximumValue)

let parallax2 = interactiveView.slider.rx.value
    .parallax(over: sliderInterval, visualizer: interactiveView.visualizer)
    .parallaxRelate(to: .interval(from: -5, to: 15), visualizer: interactiveView.visualizer)
    .parallaxFocus(on: .interval(from: 0, to: 10), visualizer: interactiveView.visualizer)
    .parallaxMorph(with: .just(.clampToUnitInterval), visualizer: interactiveView.visualizer)
    .parallaxMorph(with: .just(.oscillate(numberOfTimes: 3)), visualizer: interactiveView.visualizer)

PlaygroundPage.current.liveView = interactiveView
