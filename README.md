# Parallaxer

Craft parallax effects in Swift.

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

Parallaxer makes it simple to establish relationships between changing values in your application; 
use it to build delightful animations and tight controller interactions.

### Example use-cases

- Slow moving backdrops in a side scrolling video game.
- Hour, minute and second hands on an analog watch. 
- A download progress indicator.
- Analog joystick controller interactions.

### Parallax Transform: 

```Swift
struct ParallaxTransform {
    let interval: ParallaxInterval
    let unitPosition: Double
}
```

A parallax transform consists of two things: an *interval*, over which change is expected to occur,
and a *unit position*, a number between [0, 1], which serves as a reference point on that interval.

During your daily commute, you leave your home, hop on some form of transportation and eventually 
arrive at work. Along the way, you'll pass by various landmarks that you've seen dozens of times before, 
which give you a sense of where you are in relation to your home and the office.

If you modeled your commute as a parallax transform, its interval might be [0 miles, 12 miles] and its unit position would then indicate where you are in relation to your journey.

As you leave your home, the transform's unit position is 0, and when you reach the office, the unit position is 1. Each landmark along your commute is represented by a different unit position between 0 and 1.

Parallax transformations may be performed which alter the receiving transform's interval and/or its unit 
position. Each transformation results in a new transform which preserves some property of the original.

#### Supported transformations:

- `scale(to: ParallaxInterval)`
    - Alter the interval of the receiving transform, preserving its unit position.
- `reposition(with: PositionCurve)`
    - Alter the unit position of the receiving transform, preserving its interval.
- `focus(subinterval: ParallaxInterval)`
    - Alter both the interval and unit position of the receiving transform, preserving its parallax value.
    
### `ParallaxInterval`:

```Swift
struct ParallaxInterval {
    private let from: ValueType
    private let to: ValueType
}
```

A parallax interval is a bidirectional interval with boundaries such that `from != to`; it specifies 
the interval over which change is expected to occur.

### `PositionCurve`:

A position curve affects how a unit position progresses over the unit interval: [0, 1].

## Usage

When envisioning a parallax effect, it helps to *think in terms of intervals*:
  - First identify what is changing.
  - Then determine the interval which best represents the boundary of that change. 

### Example - Custom scroll indicator

Let's add a custom scroll indicator to a vertical-scrolling `UIScrollView`. The scroll indicator 
shall be rendered with a `UIImageView`, and it shall move up and down in relation to the scroll view's
content offset.

How might we accomplish this with Parallaxer?

#### First, identify what is changing:

1) `UIScrollView.contentOffset` - Whenever the user slides their finger up or down on the scroll view, 
the view's content offset changes accordingly.
2) `UIImageView.center` - As the scroll view's content offset changes, so too shall the vertical position 
of the scroll indicator.

#### Next, determine parallax intervals for the changes we identified:

1) The maximum scrollable distance allowed by a scroll view is a function of its content size and frame size. 
We can calculate `scrollingInterval` like so:
    ```Swift
    let maxScrollDistanceY = scrollView.contentSize.height - scrollView.frame.height
    let scrollingInterval = ParallaxInterval(from: 0, to: maxScrollDistanceY)
    ```
2) The scroll indicator shall travel up and down the full height of the scroll view's frame; this is very straight-forward:
    ```Swift
    let indicatorPositionInterval = ParallaxInterval(from: 0, to: scrollView.frame.height)
    ```

#### Finally, relate these intervals to each other:

Whenever scrolling occurs, the content offset must be transformed into a scroll-indicator position. (If you guessed 
that `ParallaxTransform` can help with that, then please enjoy this freshly baked cookie: 🍪.)
```Swift
// Create a transform representing the content offset of the scroll view.
let scrollingTransform = ParallaxTransform(
    interval: scrollingInterval,
    parallaxValue: scrollView.contentOffset.y)

// Relate the indicator's position to the scrolling transform.
let indicatorPositionTransform = scrollingTransform
    .scale(to: indicatorPositionInterval)
```

#### Tie it all together:
Using Parallaxer's RxSwift extensions, we can set all of this up declaratively in our view controller's `viewDidLoad()` 
method. 

```Swift
override func viewDidLoad() {
    super.viewDidLoad()

    // Set up views, layout, etc.
    ...

    // Calculate the scrolling interval, over which scrolling can occur.
    let maxScrollDistanceY = scrollView.contentSize.height - scrollView.frame.height
    let scrollingInterval = ParallaxInterval(from: 0, to: maxScrollDistanceY)

    // Create a transform representing the content offset of the scroll view.
    let scrollingTransform = scrollView.rx.contentOffset // RxCocoa.
        .map { return $0.y } // RxSwift.
        .parallax(over: scrollingInterval)

    // Determine the indicator's position interval, over which the indicator can move.
    let indicatorPositionInterval = ParallaxInterval(from: 0, to: scrollView.frame.height)

    // Relate the indicator's position to the scrolling transform.
    let indicatorPositionTransform = scrollingTransform
        .parallaxScale(to: indicatorPositionInterval)

    // Finally, bind the indicator parallax value to the image view's center point.
    indicatorPositionTransform
        .parallaxValue()
        .subscribe(onNext: { [unowned self] positionY in // RxSwift.
            self.indicatorImageView.center = CGPoint(
                x: self.scrollIndicator.center.x
                y: positionY)
        }
        .disposed(by: disposeBag) // RxSwift.
}
```
Note: I've commented the lines which use standard `RxSwift`/`RxCocoa` functions. Please see the 
[RxSwift documentation](https://github.com/ReactiveX/RxSwift) if you have a question about those.

### [PhotoBook](https://github.com/Parallaxer/PhotoBook) example project

Check out [PhotoBook](https://github.com/Parallaxer/PhotoBook), an example project which showcases
the Parallaxer framework.

## License

Parallaxer is maintained by [Clifton Roberts](mailto:clifton.roberts@me.com) and released
under the MIT license. See LICENSE for details.
