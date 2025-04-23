import Foundation
import Metal

public class BilateralFilter: BasicOperation {
    public var distanceNormalizationFactor: Float = 4.0 {
        didSet {
            uniformSettings["distanceNormalizationFactor"] = distanceNormalizationFactor
        }
    }
    
    public init() {
        super.init(fragmentFunctionName: "bilateralFilterFragment", numberOfInputs: 1)
    }
} 