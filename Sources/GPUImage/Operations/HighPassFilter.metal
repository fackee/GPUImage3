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
    
    int r = int(uniform.radius);
    for(int i = -r; i <= r; i++) {
        for(int j = -r; j <= r; j++) {
            float2 offset = float2(float(i), float(j)) * singleStepOffset;
            float4 color = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate + offset);
            float weight = 1.0;
            blurColor += color * weight;
            weightSum += weight;
        }
    }
    
    float4 blurredColor = blurColor / weightSum;
    return centerColor - blurredColor + 0.5;
} 