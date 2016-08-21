# Master

### Breaking

- None

### Enhancements

- None

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
