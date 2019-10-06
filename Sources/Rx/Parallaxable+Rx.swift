import RxSwift
import RxCocoa

extension ObservableType where E: Parallaxable {

    /// Create a new parallax transform on the given `interval`, with the observable element as its
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
    /// - Returns: A parallax transform composed by calling `transform()`.
    public func parallax(
        over interval: Observable<ParallaxInterval<E>>)
        -> Observable<ParallaxTransform<E>>
    {
        return Observable
            .combineLatest(interval, self)
            .map(ParallaxTransform.init(interval:parallaxValue:))
    }
}
