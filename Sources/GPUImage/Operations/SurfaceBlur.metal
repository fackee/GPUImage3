#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

typedef struct
{
    float blurRadius;
    float2 direction;
} SurfaceBlurUniform;

fragment float4 surfaceBlurFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                  texture2d<float> inputTexture [[texture(0)]],
                                  constant SurfaceBlurUniform& uniform [[buffer(1)]]) {
    constexpr sampler quadSampler;
    float2 singleStepOffset = float2(1.0 / float(inputTexture.get_width()), 1.0 / float(inputTexture.get_height()));
    float4 centerColor = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    float4 blurColor = float4(0.0);
    float weightSum = 0.0;
    
    // 使用高斯权重
    const float weights[5] = {0.227027, 0.1945946, 0.1216216, 0.054054, 0.016216};
    
    // 中心点
    blurColor += centerColor * weights[0];
    weightSum += weights[0];
    
    // 只采样5个点，使用高斯权重
    for(int i = 1; i < 5; i++) {
        float2 offset = float2(float(i)) * singleStepOffset * uniform.direction;
        float4 color1 = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate + offset);
        float4 color2 = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate - offset);
        
        float weight = weights[i];
        float colorWeight1 = length(color1.rgb - centerColor.rgb);
        float colorWeight2 = length(color2.rgb - centerColor.rgb);
        
        weight *= exp(-(colorWeight1 * colorWeight1) / (2.0 * 0.1 * 0.1));
        blurColor += color1 * weight;
        weightSum += weight;
        
        weight = weights[i];
        weight *= exp(-(colorWeight2 * colorWeight2) / (2.0 * 0.1 * 0.1));
        blurColor += color2 * weight;
        weightSum += weight;
    }
    
    return blurColor / weightSum;
} 
