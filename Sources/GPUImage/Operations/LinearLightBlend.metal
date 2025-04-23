#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

fragment float4 linearLightBlendFragment(TwoInputVertexIO fragmentInput [[stage_in]],
                                       texture2d<float> inputTexture [[texture(0)]],
                                       texture2d<float> inputTexture2 [[texture(1)]]) {
    constexpr sampler quadSampler;
    float4 baseColor = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    float4 blendColor = inputTexture2.sample(quadSampler, fragmentInput.textureCoordinate2);
    
    // 线性光混合模式
    float4 result;
    result.r = baseColor.r < 0.5 ? max(0.0, baseColor.r + 2.0 * blendColor.r - 1.0) : min(1.0, baseColor.r + 2.0 * (blendColor.r - 0.5));
    result.g = baseColor.g < 0.5 ? max(0.0, baseColor.g + 2.0 * blendColor.g - 1.0) : min(1.0, baseColor.g + 2.0 * (blendColor.g - 0.5));
    result.b = baseColor.b < 0.5 ? max(0.0, baseColor.b + 2.0 * blendColor.b - 1.0) : min(1.0, baseColor.b + 2.0 * (blendColor.b - 0.5));
    result.a = baseColor.a;
    
    // 50%透明度混合
    return (baseColor + result) * 0.5;
} 