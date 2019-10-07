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

The purpose of Parallaxer is to provide a simple, declarative interface for establishing relationships
between changing values in your application; use it to build delightful animations or tight controller interactions.

### Examples of parallax

- Slow moving backdrops in a side scrolling video game.
- Hour, minute and second hands on an analog watch. 
- A download progress indicator.
- Analog joystick controller input.

### `ParallaxTransform`: 

A parallax transform consists of a *parallax interval*, over which change is expected to occur,
as well as a *unit position*, a number between [0, 1], which serves as a reference point on that 
interval.

Transformations may be performed which alter the receiving transform's interval and/or its unit 
position. Each parallax transformation results in a new transform which preserves certain properties
from the original.

#### Supported transformations:

- `scale(to: ParallaxInterval)`
    - Alter the interval of the receiving transform, preserving its unit position.
- `reposition(with: PositionCurve)`
    - Alter the unit position of the receiving transform, preserving its interval.
- `focus(subinterval: ParallaxInterval)`
    - Alter both the interval and unit position of the receiving transform, preserving its parallax value.
    
### `ParallaxInterval`:

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
