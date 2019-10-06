# Parallaxer

Craft interactive parallax effects in Swift.

## Requirements
- Swift 5

## Installation

#### With [Carthage](https://github.com/Carthage/Carthage)

```
github "Parallaxer/Parallaxer"
```

#### With [CocoaPods](https://github.com/CocoaPods/CocoaPods)

```
use_frameworks!
pod 'Parallaxer'
```

## Overview

In the context of this framework, *parallax* is a relationship between two reference points, 
specified as a `ParallaxTransform`.

### `ParallaxTransform`: 

A parallax transform consists of a *parallax interval*, over which change is expected to occur,
as well as a *unit position*, a number between [0, 1], which serves as a reference point on that 
interval.

Transformations may be performed which alter the receiving transform's interval and/or its unit 
position. Each parallax transformation results in a new transform.

- Supported transformations:
    - `scale(to: ParallaxInterval)`
    Alter the interval of the receiving transform, preserving its unit position.
    - `reposition(with: PositionCurve)`
    Alter the unit position of the receiving transform, preserving its interval.
    - `focus(subinterval: ParallaxInterval)`
    Alter both the interval and unit position of the receiving transform, but preserve its parallax value.
    
### `ParallaxInterval`:

A parallax interval is a bidirectional interval with boundaries such that `from != to`; it specifies 
the interval over which change is expected to occur.

### `PositionCurve`:

A position curve affects how a unit position changes.

## Usage

While crafting a parallax effect, it helps to first identify what is changing, and then determine
interval(s) which best represent the boundaries of those changes.

### Ex1 (simple) - Convert values to a percentage of the interval [0, 4].

Let's start with a simple example that takes a value on some interval and determines its percentage of 
that interval.
```swift
let root = Observable.from([0, 1, 2, 3, 4])
    .parallax(over: .interval(from: 0, to: 4))

let percentage = root
    .parallaxScale(to: .interval(from: 0, to: 100))
    .parallaxValue()
    
// Signals: 0, 25, 50, 75, 100
```

### Ex2 (intermediate) - Custom scroll indicator

Let's say we want to add a custom scroll indicator to a vertical-scrolling `UIScrollView`. The scroll indicator 
shall be rendered with a `UIImageView`, and it shall move up and down in relation to the scroll view's
content offset.

How might we accomplish this with **Parallaxer**?

First, let's answer the question, "What is changing?":
    1) `UIScrollView.contentOffset` - Whenever the user slides their finger up or down on the scroll view, 
    the view's content offset changes accordingly.
    2) `UIImageView.center` - As the scroll view's content offset changes, so too shall the vertical position 
    of the scroll indicator.

Now that we've identified what is changing, let's determine the parallax intervals which bound those changes.
    1) The maximum scrollable distance allowed by a scroll view is a function of its content size and the size of its
    frame. And so we can calculate `scrollingInterval` like so:
    ```
    let maxScrollDistanceY = scrollView.contentSize.height - scrollView.frame.height
    let scrollingInterval = ParallaxInterval(from: 0, to: maxScrollDistanceY)
    ```
    2) The scroll indicator shall travel up and down the full height of the scroll view's frame, very straight-forward:
    ```
    let indicatorPositionInterval = ParallaxInterval(from: 0, to: scrollView.frame.height)
    ```

Finally, we need to relate these intervals somehow, such that whenever scrolling occurs, the content offset
is transformed into a scroll-indicator position. If you guessed that `ParallaxTransform` can help with that,
then you are!
```swift
// Create a transform representing the content offset of the scroll view.
let scrollingTransform = ParallaxTransform(
    interval: scrollingInterval,
    parallaxValue: scrollView.contentOffset.y)
    
// Relate the indicator's position to the scrolling transform.
let indicatorPositionTransform = scrollingTransform
    .scale(to: indicatorPositionInterval)
```

Using RxSwift extensions, we can set all of this up declaratively in our view controller's `viewDidLoad()` method.
```swift
override func viewDidLoad() {
    super.viewDidLoad()
    
    ... // Set up views, layout, etc.
    
    // Calculate the scrolling interval, over which scrolling can occur.
    let maxScrollDistanceY = scrollView.contentSize.height - scrollView.frame.height
    let scrollingInterval = ParallaxInterval(from: 0, to: maxScrollDistanceY)
    
    // Create a transform representing the content offset of the scroll view.
    let scrollingTransform = scrollView.rx.contentOffset
        .map { return $0.y }
        .parallax(over: scrollingInterval)
    
    // Determine the indicator's position interval, over which the indicator can move.
    let indicatorPositionInterval = ParallaxInterval(from: 0, to: scrollView.frame.height)
    
    // Relate the indicator's position to the scrolling transform.
    let indicatorPositionTransform = scrollingTransform
        .parallaxScale(to: indicatorPositionInterval)
        
    // Finally, bind the indicator position to the indicator's center point.
    indicatorPositionTransform
        .parallaxValue()
        .subscribe(onNext: { [unowned self] positionY in
            self.indicatorImageView.center = CGPoint(
                x: self.scrollIndicator.center.x
                y: positionY)
        }
        .disposed(by: disposeBag)
}
```

### [PhotoBook](https://github.com/Parallaxer/PhotoBook) example project

Check out [PhotoBook](https://github.com/Parallaxer/PhotoBook), an example project which showcases
the Parallaxer framework.

## License

Parallaxer is maintained by [Clifton Roberts](mailto:clifton.roberts@me.com) and released
under the MIT license. See LICENSE for details.
