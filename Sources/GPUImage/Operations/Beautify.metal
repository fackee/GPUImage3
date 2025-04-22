//
//  File.metal
//  GPUImage
//
//  Created by zhujianxin04 on 2025/4/22.
//

#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

typedef struct
{
    float smoothDegree;      // 磨皮程度
    float brightness;        // 亮度调整
} BeautifyUniform;

fragment half4 beautifyFragment(TwoInputVertexIO fragmentInput [[stage_in]],
                              texture2d<half> inputTexture [[texture(0)]],
                              texture2d<half> inputTexture2 [[texture(1)]],
                              texture2d<half> inputTexture3 [[texture(2)]],
                              constant BeautifyUniform& uniform [[ buffer(1) ]])
{
    constexpr sampler quadSampler;
    
    // 获取输入纹理的采样结果
    half4 bilateral = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    half4 canny = inputTexture2.sample(quadSampler, fragmentInput.textureCoordinate2);
    half4 origin = inputTexture3.sample(quadSampler, fragmentInput.textureCoordinate);
    
    // 提取原图RGB分量
    half r = origin.r;
    half g = origin.g;
    half b = origin.b;
    
    half4 smooth;
    
    // 肤色检测和边缘保护
    bool isSkin = (canny.r < 0.2h &&
                  r > 0.3725h &&
                  g > 0.1568h &&
                  b > 0.0784h &&
                  r > b &&
                  (max(max(r, g), b) - min(min(r, g), b)) > 0.0588h &&
                  abs(r-g) > 0.0588h);
    
    // 根据是否是皮肤区域决定是否进行磨皮
    if (isSkin) {
        smooth = mix(bilateral, origin, 1.0h - half(uniform.smoothDegree));
    } else {
        smooth = origin;
    }
    
    // 对数曲线调整
    const half adjustment = 0.2h;
    const half base = 1.2h;
    smooth.r = log(1.0h + adjustment * smooth.r) / log(base);
    smooth.g = log(1.0h + adjustment * smooth.g) / log(base);
    smooth.b = log(1.0h + adjustment * smooth.b) / log(base);
    
    // 亮度调整
    smooth.rgb *= half(uniform.brightness);
    
    return smooth;
}
