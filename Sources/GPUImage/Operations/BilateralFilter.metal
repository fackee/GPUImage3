#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

struct VertexInput {
    float4 position [[position]];
    float2 textureCoordinate;
};

fragment float4 bilateralFilterFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                      texture2d<float> inputTexture [[texture(0)]],
                                      constant float &distanceNormalizationFactor [[buffer(0)]]) {
    constexpr sampler quadSampler;
    float2 singleStepOffset = float2(1.0 / float(inputTexture.get_width()), 1.0 / float(inputTexture.get_height()));
    float4 centerColor = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    float4 blurColor = float4(0.0);
    float weightSum = 0.0;
    
    for(int i = -2; i <= 2; i++) {
        for(int j = -2; j <= 2; j++) {
            float2 offset = float2(float(i), float(j)) * singleStepOffset;
            float4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate + offset);
            float weight = exp(-(float(i * i + j * j) / (2.0 * distanceNormalizationFactor * distanceNormalizationFactor)));
            float colorWeight = length(color.rgb - centerColor.rgb);
            weight *= exp(-(colorWeight * colorWeight) / (2.0 * 0.1 * 0.1));
            blurColor += color * weight;
            weightSum += weight;
        }
    }
    
    return blurColor / weightSum;
} 