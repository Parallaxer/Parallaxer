private let kUnitInterval = ParallaxInterval<Double>(from: 0, to: 1)

/**
 A private protocol which allows nested parallax effects of varying types.
 */
private protocol ParallaxInheritable {
    
    func inheritProgress(_ progress: Double)
}

/**
 A `ParallaxEffect` specifies an interval over which a change in value is expected; parallax effects are
 achieved by composing a tree of `ParallaxEffect` objects, or parallax tree.
 
 A root effect is responsible for seeding the parallax tree. See `seed(withValue:)`.
 
 As a root behavior's value changes, progress over its interval is calculated and inherited by its nested
 effects. The nested effects use the inheritted progress to express values relative to their own interval;
 one may subscribe to these values and use them to update other properties. See `onChange`.
 */
public struct ParallaxEffect<ValueType: Parallaxable> {
    
    /// A type which represents a subinterval, specified over the unit interval [0, 1].
    public typealias Subinterval = ParallaxInterval<Double>
    
    /// Closure that is called whenever `self` expresses a value.
    public var onChange: ((newValue: ValueType) -> Void)?

    private let interval: ParallaxInterval<ValueType>
    private let clampsInheritedProgress: Bool
    private let inheritedProgressTransform: ParallaxCurve
    private var inheritors = [Subinterval: [ParallaxInheritable]]()

    /**
     Initialize a `ParallaxEffect`, a node in a parallax tree.
     
     - parameter interval:          The interval over which change is expected.
     - parameter progressCurve:     How inherited progress is transformed. Default is `.linear`.
     - parameter isClamped:         Whether inheritted progress is clamped to the unit interval before it is
                                    transformed by `progressCurve`. Default is `false`.
     - parameter onChange:          Closure that is called whenever the effect expresses a new value.
     */
    public init(interval: ParallaxInterval<ValueType>, progressCurve: ParallaxCurve = .linear,
                isClamped: Bool = false, onChange: ((ValueType) -> Void)? = nil)
    {
        self.interval = interval
        self.onChange = onChange
        self.inheritedProgressTransform = progressCurve
        self.clampsInheritedProgress = isClamped
    }
    
    /**
     Add a nested effect to `self` which shall inherit its progress.
     
     - parameter effect:        The effect to add, which shall inherit progress from `self`.
     - parameter subinterval:   The subinterval over which `effect` shall inherit progress. Subintervals are
                                specified over the unit interval [0, 1]. Default is the unit interval.
     */
    public mutating func addEffect<NestedValueType: Parallaxable>(_ effect: ParallaxEffect<NestedValueType>,
                                   subinterval: Subinterval? = nil)
    {
        let interval = subinterval ?? kUnitInterval
        var inheritors = self.inheritors[interval] ?? [ParallaxInheritable]()
        inheritors.append(effect)
        self.inheritors[interval] = inheritors
    }
    
    /**
     Seed the parallax tree. Call this method on the root effect whenever its value should change.
     
     - note: Triggers `onChange` in the root and nested effects.
     
     - parameter value: The seed value from which all other values in the parallax tree shall be determined.
     */
    public func seed(withValue value: ValueType) {
        let progress = self.interval.progress(forValue: value)
        self.setProgress(progress)
    }
    
    // MARK: Private functions
    
    private func setProgress(_ progress: Double) {
        self.expressValueIfNeeded(forProgress: progress)
        for (subinterval, inheritors) in self.inheritors {
            let progress = self.translateProgress(progress, overSubinterval: subinterval)
            inheritors.forEach { $0.inheritProgress(progress) }
        }
    }
    
    private func expressValueIfNeeded(forProgress progress: Double) {
        guard let onChange = self.onChange else {
            return
        }

        let value = self.interval.value(forProgress: progress)
        onChange(newValue: value)
    }
    
    private func translateProgress(_ progress: Double, overSubinterval subinterval: Subinterval) -> Double {
        if subinterval == kUnitInterval {
            return progress
        }
        
        return subinterval.progress(forValue: progress)
    }
}

extension ParallaxEffect: ParallaxInheritable {
    
    private func inheritProgress(_ progress: Double) {
        let clamped = self.clampsInheritedProgress ? min(1, max(0, progress)) : progress
        let progress = self.inheritedProgressTransform.transform(progress: clamped)
        self.setProgress(progress)
    }
}
