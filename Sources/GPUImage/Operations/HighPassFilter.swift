import Foundation
import Metal

public class HighPassFilter: BasicOperation {
    public var radius: Float = 1.0 {
        didSet {
            uniformSettings["radius"] = radius
        }
    }
    
    public init() {
        super.init(fragmentFunctionName: "highPassFragment", numberOfInputs: 1)
        ({ radius = 1.0 })()
    }
}
