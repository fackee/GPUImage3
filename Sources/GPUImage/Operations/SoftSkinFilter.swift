import Foundation
import Metal

public class SoftSkinFilter: OperationGroup {
    public var blurRadius: Float = 28.0 {
        didSet {
            surfaceBlur.blurRadius = blurRadius
        }
    }
    
    let surfaceBlur = SurfaceBlur()
    let highPass = HighPassFilter()
    let linearLightBlend = LinearLightBlend()
    
    public override init() {
        super.init()
        
        ({ blurRadius = 28.0 })()
        
        self.configureGroup { input, output in
            input --> self.surfaceBlur --> self.linearLightBlend
            input --> self.highPass --> self.linearLightBlend
            self.linearLightBlend --> output
        }
    }
} 