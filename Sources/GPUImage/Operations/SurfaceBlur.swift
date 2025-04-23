import Foundation
import Metal

public class SurfaceBlur: OperationGroup {
    public var blurRadius: Float = 28.0 {
        didSet {
            horizontalBlur.blurRadius = blurRadius
            verticalBlur.blurRadius = blurRadius
        }
    }
    
    let horizontalBlur = BasicOperation(fragmentFunctionName: "surfaceBlurFragment", numberOfInputs: 1)
    let verticalBlur = BasicOperation(fragmentFunctionName: "surfaceBlurFragment", numberOfInputs: 1)
    
    public override init() {
        super.init()
        
        ({ blurRadius = 28.0 })()
        
        // 设置水平方向
        horizontalBlur.uniformSettings["direction"] = [1.0, 0.0]
        
        // 设置垂直方向
        verticalBlur.uniformSettings["direction"] = [0.0, 1.0]
        
        self.configureGroup { input, output in
            input --> self.horizontalBlur --> self.verticalBlur --> output
        }
    }
} 