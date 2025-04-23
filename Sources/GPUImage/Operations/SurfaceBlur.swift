import Foundation
import Metal

public class SurfaceBlur: BasicOperation {
    public var blurRadius: Float = 28.0 {
        didSet {
            uniformSettings["blurRadius"] = blurRadius
        }
    }
    
    public init() {
        super.init(fragmentFunctionName: "surfaceBlurFragment", numberOfInputs: 1)
        ({ blurRadius = 28.0 })()
    }
} 