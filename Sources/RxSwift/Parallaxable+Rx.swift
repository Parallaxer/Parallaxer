import RxSwift
import RxCocoa

extension ObservableType where Element: Parallaxable {

    /// Create a new parallax transform on the given `interval`, with the sequence's element as its
    /// `parallaxValue`.
    ///
    /// A parallax transform is the result of one or more parallax transformations, which can be performed
    /// using any of the following operators:
    ///   - `parallaxScale(to:)`
    ///   - `parallaxReposition(with:)`
    ///   - `parallaxFocus(subinterval:)`
    ///
    /// A parallax transform can be converted back into a value suitable for the user interface with the
    /// following operator:
    ///   - `parallaxValue()`
    ///
    /// - Parameter interval: An interval over which change is expected to occur.
    /// - Returns: A parallax transform on the given `interval`, with the sequence's element as its
    /// `parallaxValue`.
    public func parallax(
        over interval: Observable<ParallaxInterval<Element>>)
        -> Observable<ParallaxTransform<Element>>
    {
        return Observable
            .combineLatest(interval, self)
            .map(ParallaxTransform.init(interval:parallaxValue:))
    }
}
