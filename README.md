# Parallaxer

Parallaxer is a framework for crafting parallax effects in Swift.

## Requirements
- Swift 4.2

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

Parallax effects are achieved by composing a tree of `ParallaxEffect` objects,
or *parallax tree*. Below is a brief description of the types used to construct
nodes in a parallax tree. See source files for more documentation.

- `ParallaxEffect`:
    - A node in a parallax tree. 
    - Values are set, or seeded, at the root.
    - Nested effects express values relative to their parent.

- `ParallaxInterval`:
    - A bidirectional interval with boundaries such that `from != to`.

- `ParallaxCurve`:
    - Used by an effect to transform progress inherited from its parent.

## Usage

### Percentage example

```swift
import Parallaxer
var percentage: Double?

// Define an effect that expresses a value as a percentage of its parent interval.
let calculatePercentage = ParallaxEffect(
    interval: ParallaxInterval(from: 0, to: 100),
    change:   { percentage = $0 as Double }
)

var root = ParallaxEffect(interval: ParallaxInterval(from: 0, to: 4))
root.addEffect(calculatePercentage)

root.seed(withValue: 2)
print(percentage) // Output: 50.0
```

### [PhotoBook](https://github.com/Parallaxer/PhotoBook) example project

Check out [PhotoBook](https://github.com/Parallaxer/PhotoBook), an example project which showcases
the Parallaxer framework.

## License

Parallaxer is maintained by [Clifton Roberts](mailto:clifton.roberts@me.com) and released
under the MIT license. See LICENSE for details.
