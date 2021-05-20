/// Errors one might encounter while using Parallaxer.
public enum ParallaxError: Error {
    
    /// Zero-length intervals aren't supported because they cause divide-by-zero runtime errors.
    case zeroLengthInterval
}
