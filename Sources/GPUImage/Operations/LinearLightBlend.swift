import Foundation
import Metal

public class LinearLightBlend: BasicOperation {
    public init() {
        super.init(fragmentFunctionName: "linearLightBlendFragment", numberOfInputs: 2)
    }
} 