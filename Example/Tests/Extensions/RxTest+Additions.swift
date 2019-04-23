import RxSwift
import RxTest
import RxCocoa

extension TestScheduler {

    /// From a list of values, return a list of recorded events.
    ///
    /// - Parameter values: The values to map to chronological events.
    /// - Returns: Events, in increasing chronological order.
    static func chronologicalEvents<Element>(from values: [Element]) -> [Recorded<Event<Element>>] {
        return values.enumerated().map { arg -> Recorded<Event<Element>> in
            return Recorded.next(arg.offset + 200, arg.element)
        }
    }

    public func createHotObservable<Element>(withChronologicalValues values: [Element])
        -> TestableObservable<Element>
    {
        return createHotObservable(TestScheduler.chronologicalEvents(from: values))
    }

    public func createColdObservable<Element>(withChronologicalValues values: [Element])
        -> TestableObservable<Element>
    {
        return createColdObservable(TestScheduler.chronologicalEvents(from: values))
    }
}

extension TestScheduler {

    /// Create a `TestableObserver` that subscribes to and records all events from `source`, up to the
    /// specified virtual `disposeTime`.
    ///
    /// - Parameters:
    ///   - source:         An observable whose events shall be recorded by the testable observer.
    ///   - disposeTime:    A virtual time at which the testable observer shall dispose of its subscription.
    ///                     The default is 10000.
    /// - Returns:  A testable observer that subscribes to and records all events from `source`, along with
    ///             the virtual timestamp at which said events occur. The observer's subscription shall be
    ///             disposed of at the specified `disposeTime`.
    func record<O: ObservableConvertibleType>(_ source: O, disposeTime: TestTime = 10000)
        -> TestableObserver<O.E>
    {
        let observer = createObserver(O.E.self)
        let disposable = source.asObservable().bind(to: observer)
        scheduleAt(disposeTime) {
            disposable.dispose()
        }
        return observer
    }
}
