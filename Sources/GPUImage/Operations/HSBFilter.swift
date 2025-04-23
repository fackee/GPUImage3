import Foundation
import Metal

public class HSBFilter: BasicOperation {
    public var brightness: Float = 1.0 {
        didSet {
            uniformSettings["brightness"] = brightness
        }
    }
    
    public var saturation: Float = 1.0 {
        didSet {
            uniformSettings["saturation"] = saturation
        }
    }
    
    public init() {
        super.init(fragmentFunctionName: "hsbFilterFragment", numberOfInputs: 1)
        ({ brightness = 1.0 })()
        ({ saturation = 1.0 })()
    }
} 