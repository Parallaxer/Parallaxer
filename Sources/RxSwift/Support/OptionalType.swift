/// Protocol which serves as a optional type-constraint for generic type extensions.
///
/// Taken from https://medium.com/@victor.pavlychko/generic-optional-handling-in-swift-7c8647e71223
public protocol OptionalType: ExpressibleByNilLiteral {

    associatedtype WrappedType

    /// The value as a wrapped optional.
    var asOptional: WrappedType? { get }
}

extension Optional: OptionalType {

    public var asOptional: Wrapped? {
        return self
    }
}
