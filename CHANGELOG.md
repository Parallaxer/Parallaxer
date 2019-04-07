# Master

### Breaking

- None

### Enhancements

- None

### Bug Fixes

- None

# 3.0.2

### Breaking

- None

### Enhancements

- None

### Bug Fixes

- Fix wrong version number in podspec.

# 3.0.1

### Breaking

- None

### Enhancements

- Modernized project for Swift 4.2.

### Bug Fixes

- None

# 3.0.0

### Breaking

- Modernized code and project for Swift 4.0.
  [#7](https://github.com/Parallaxer/Parallaxer/pull/7)

### Enhancements

- Updated `README` with Cocoapods integration and Swift 3.0 requirement.
  [#6](https://github.com/Parallaxer/Parallaxer/pull/6)

### Bug Fixes

- None

# 2.1.0

### Breaking

- Support for Swift in Xcode v8 beta 6.
  [#4](https://github.com/Parallaxer/Parallaxer/pull/4)

### Enhancements

- Update tests such that generic types are specified implicitly.
  [#3](https://github.com/Parallaxer/Parallaxer/pull/3)

### Bug Fixes

- None

# 2.0.0

### Breaking

- API changes:
  [#1](https://github.com/Parallaxer/Parallaxer/pull/1)
    - `onChange` is now `change`
    - `ParallaxEffect(interval:progressCurve:isClamped:onChange:)` shortened to
      `ParallaxEffect(over:curve:clamped:change:)`
    - `addEffect(subinterval:)` is now `addEffect(toSubinterval:)`

### Enhancements

- Cleaned up tests.
  [#1](https://github.com/Parallaxer/Parallaxer/pull/1)

### Bug Fixes

- None

# 1.0.0

First release.
