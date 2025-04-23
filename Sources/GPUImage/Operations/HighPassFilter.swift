import Foundation
import Metal

public class HighPassFilter: OperationGroup {
    public var radius: Float = 1.0 {
        didSet {
            horizontalBlur.radius = radius
            verticalBlur.radius = radius
        }
    }
    
    let horizontalBlur = BasicOperation(fragmentFunctionName: "highPassFragment", numberOfInputs: 1)
    let verticalBlur = BasicOperation(fragmentFunctionName: "highPassFragment", numberOfInputs: 1)
    
    public override init() {
        super.init()
        
        ({ radius = 1.0 })()
        
        // 设置水平方向
        horizontalBlur.uniformSettings["direction"] = [1.0, 0.0]
        
        // 设置垂直方向
        verticalBlur.uniformSettings["direction"] = [0.0, 1.0]
        
        self.configureGroup { input, output in
            input --> self.horizontalBlur --> self.verticalBlur --> output
        }
    }
}
