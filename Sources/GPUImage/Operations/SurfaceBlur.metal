#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

typedef struct
{
    float blurRadius;
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
    
    // 水平和垂直方向的采样
    for(int i = 1; i < 5; i++) {
        float2 offset = float2(float(i)) * singleStepOffset * uniform.blurRadius;
        
        // 水平方向
        float2 horizontalOffset = float2(offset.x, 0.0);
        float4 colorH1 = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate + horizontalOffset);
        float4 colorH2 = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate - horizontalOffset);
        
        // 垂直方向
        float2 verticalOffset = float2(0.0, offset.y);
        float4 colorV1 = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate + verticalOffset);
        float4 colorV2 = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate - verticalOffset);
        
        float weight = weights[i];
        
        // 计算颜色权重
        float colorWeightH1 = length(colorH1.rgb - centerColor.rgb);
        float colorWeightH2 = length(colorH2.rgb - centerColor.rgb);
        float colorWeightV1 = length(colorV1.rgb - centerColor.rgb);
        float colorWeightV2 = length(colorV2.rgb - centerColor.rgb);
        
        // 应用高斯权重
        float finalWeightH1 = weight * exp(-(colorWeightH1 * colorWeightH1) / (2.0 * 0.1 * 0.1));
        float finalWeightH2 = weight * exp(-(colorWeightH2 * colorWeightH2) / (2.0 * 0.1 * 0.1));
        float finalWeightV1 = weight * exp(-(colorWeightV1 * colorWeightV1) / (2.0 * 0.1 * 0.1));
        float finalWeightV2 = weight * exp(-(colorWeightV2 * colorWeightV2) / (2.0 * 0.1 * 0.1));
        
        blurColor += colorH1 * finalWeightH1 + colorH2 * finalWeightH2 + 
                    colorV1 * finalWeightV1 + colorV2 * finalWeightV2;
        weightSum += finalWeightH1 + finalWeightH2 + finalWeightV1 + finalWeightV2;
    }
    
    return blurColor / weightSum;
} 
