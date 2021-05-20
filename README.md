# Parallaxer

Craft parallax effects in Swift.

## Requirements
- Swift 5

## Installation

#### With [CocoaPods](https://github.com/CocoaPods/CocoaPods)

```
use_frameworks!
pod 'Parallaxer'
```

## Overview

Parallaxer makes it easy to establish relationships between changing values in your application; 
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
    let position: Double
}
```

A parallax transform consists of two things: an *interval*, over which change is expected to occur,
and a *position*, a number between [0, 1], which serves as a reference point on that interval.

During your daily commute, you leave your home, hop on some form of transportation and eventually 
arrive at work. Along the way, you'll pass by various landmarks that you've seen dozens of times before, 
which give you a sense of where you are in relation to your home and the office.

If you modeled your commute as a parallax transform, its interval might be [0 miles, 12 miles] and its 
position would then indicate where you are in relation to your journey.

As you leave your home, the transform's position is 0, and when you reach the office, the position is 1. 
Each landmark along your commute is represented by a different position between 0 and 1.

Parallax operators alter a transform's interval and/or its position. Each operation results 
in a new transform which preserves some property of the original.

#### Operators:

- `relate(to: ParallaxInterval)`
    - Alter the interval of the receiving transform, preserving its position.
- `morph(with: PositionCurve)`
    - Alter the position of the receiving transform, preserving its interval.
- `focus(on: ParallaxInterval)`
    - Alter both the interval and position of the receiving transform, preserving its parallax value.
    
### `ParallaxInterval`:

```Swift
struct ParallaxInterval {
    let from: ValueType
    let to: ValueType
}
```

A parallax interval is a bidirectional interval with boundaries such that `from != to`; it specifies 
the interval over which change is expected to occur.

### `PositionCurve`:

A position curve affects how a position changes over the unit interval: [0, 1].

## Usage

When envisioning a parallax effect, it helps to "think in terms of intervals":
  - What values are changing, how are they related?
  - For each changing value, what interval best represents the boundary of that change?

### Example - Custom scroll indicator

Let's add a custom scroll indicator to a vertical-scrolling `UIScrollView`. The scroll indicator 
shall be rendered with a `UIImageView`, and it shall move up and down in relation to the scroll view's
content offset.

How might we accomplish this with Parallaxer?

#### What values are changing, how are they related?

There are two changing values worth noting:
1) `UIScrollView.contentOffset` - Whenever the user slides their finger up or down on the scroll view, 
the view's content offset changes accordingly.
2) `UIImageView.center` - As the scroll view's content offset changes, so too shall the vertical position 
of the scroll indicator.

#### What interval best represents the boundary of that change?

1) The maximum scrollable distance allowed by a scroll view is a function of its content size and frame size. 
We can calculate `scrollingInterval` like so:
    ```Swift
    let maxScrollDistanceY = scrollView.contentSize.height - scrollView.frame.height
    let scrollingInterval = ParallaxInterval(from: 0, to: maxScrollDistanceY)
    ```
2) The scroll indicator shall travel up and down the full height of the scroll view's frame; this is straight-forward:
    ```Swift
    let indicatorInterval = ParallaxInterval(from: 0, to: scrollView.frame.height)
    ```

#### Finally, relate these intervals to each other using transform operations:

Whenever scrolling occurs, the indicator's position on the screen needs to change; `ParallaxTransform` can 
help with that.
```Swift
// Create a transform representing the content offset of the scroll view.
let scrollingTransform = ParallaxTransform(
    interval: scrollingInterval,
    parallaxValue: scrollView.contentOffset.y)

// Relate the scrolling transform to the indicator's position.
let indicatorTransform = scrollingTransform
    .relate(to: indicatorInterval)
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
    let scrollingTransform = scrollView.rx.contentOffset
        .map { return $0.y }
        .parallax(over: scrollingInterval)

    // Determine the indicator interval, over which the indicator can move.
    let indicatorInterval = ParallaxInterval(from: 0, to: scrollView.frame.height)

    // Relate the scrolling transform to the indicator.
    let indicatorTransform = scrollingTransform
        .parallaxRelate(to: indicatorInterval)

    // Finally, bind the indicator parallax value to the image view's center point.
    indicatorTransform
        .parallaxValue()
        .subscribe(onNext: { [weak self] positionY in
            guard let self = self else {
                return
            }
            self.indicatorImageView.center = CGPoint(
                x: self.scrollIndicator.center.x
                y: positionY)
        }
        .disposed(by: disposeBag)
}
```
Note: This example uses a few standard `RxSwift`/`RxCocoa` functions, such as `map()`, `subscribe(onNext:)` and `disposed(by:)`. Please see the 
[RxSwift documentation](https://github.com/ReactiveX/RxSwift) if you have a question about those.

### [PhotoBook](https://github.com/Parallaxer/PhotoBook) example project

Check out [PhotoBook](https://github.com/Parallaxer/PhotoBook), an example project which showcases
the Parallaxer framework.

## License

Parallaxer is maintained by [Clifton Roberts](mailto:clifton.roberts@me.com) and released
under the MIT license. See LICENSE for details.
