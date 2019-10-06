import RxSwift

extension ObservableType where E: OptionalType {

    /// Skip nil signals. Observable element shall become non-optional.
    public func skipNil() -> Observable<E.WrappedType> {
        return flatMap { element -> Observable<E.WrappedType> in
            return element.asOptional.map(Observable.just) ?? .empty()
        }
    }
}
