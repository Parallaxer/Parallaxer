import RxSwift

extension ObservableType where Element: OptionalType {

    /// Skip nil signals. Observable element shall become non-optional.
    public func skipNil() -> Observable<Element.WrappedType> {
        return flatMap { element -> Observable<Element.WrappedType> in
            return element.asOptional.map(Observable.just) ?? .empty()
        }
    }
}
