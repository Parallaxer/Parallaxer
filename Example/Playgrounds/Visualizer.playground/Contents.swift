//: A UIKit based Playground for presenting user interface
  
import PlaygroundSupport
import Parallaxer
import RxSwift
import RxCocoa
import UIKit

// MARK: Static visualization example.

let visualizer = ParallaxView(frame: CGRect(x: 0, y: 0, width: 500, height: 600))

let parallax = Observable.just(7)
    .parallax(over: .interval(from: 0, to: 10), visualizer: visualizer)
    .parallaxRelate(to: .interval(from: -5, to: 15), visualizer: visualizer)
    .parallaxFocus(on: .interval(from: 0, to: 10), visualizer: visualizer)
    .parallaxMorph(with: .just(.clampToUnitInterval), visualizer: visualizer)
    .parallaxMorph(with: .just(.oscillate(numberOfTimes: 3)), visualizer: visualizer)

visualizer


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
