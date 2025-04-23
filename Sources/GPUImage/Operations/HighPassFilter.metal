#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

typedef struct
{
    float radius;
} HighPassUniform;

fragment float4 highPassFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                               texture2d<float> inputTexture [[texture(0)]],
                               constant HighPassUniform& uniform [[ buffer(1) ]]) {
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
        float2 offset = float2(float(i)) * singleStepOffset * uniform.radius;
        
        // 水平方向
        float2 horizontalOffset = float2(offset.x, 0.0);
        float4 colorH1 = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate + horizontalOffset);
        float4 colorH2 = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate - horizontalOffset);
        
        // 垂直方向
        float2 verticalOffset = float2(0.0, offset.y);
        float4 colorV1 = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate + verticalOffset);
        float4 colorV2 = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate - verticalOffset);
        
        float weight = weights[i];
        blurColor += (colorH1 + colorH2 + colorV1 + colorV2) * weight;
        weightSum += weight * 4.0;
    }
    
    float4 blurredColor = blurColor / weightSum;
    return centerColor - blurredColor + 0.5;
} 