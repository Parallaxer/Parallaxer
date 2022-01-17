import Combine

extension Publisher where Output: Parallaxable, Failure == Never {
    public func parallax(
        over interval: AnyPublisher<ParallaxInterval<Output>, ParallaxError>)
    -> AnyPublisher<ParallaxTransform<Output>, ParallaxError>
    {
        return self
            .setFailureType(to: ParallaxError.self)
            .combineLatest(interval) { ($1, $0) }
            .map(ParallaxTransform.init(interval:parallaxValue:))
            .eraseToAnyPublisher()
    }
}
