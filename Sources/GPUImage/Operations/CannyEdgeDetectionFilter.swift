import Foundation
import Metal

public class CannyEdgeDetectionFilter: BasicOperation {
    public var threshold: Float = 0.5 {
        didSet {
            uniformSettings["threshold"] = threshold
        }
    }
    
    public init() {
        super.init(fragmentFunctionName: "cannyEdgeDetectionFragment", numberOfInputs: 1)
        ({ threshold = 0.5 })()
    }
} 