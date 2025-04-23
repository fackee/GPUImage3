#include <metal_stdlib>
#include "OperationShaderTypes.h"
using namespace metal;

struct VertexInput {
    float4 position [[position]];
    float2 textureCoordinate;
};

fragment float4 cannyEdgeDetectionFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                         texture2d<float> inputTexture [[texture(0)]],
                                         constant float &threshold [[buffer(0)]]) {
    constexpr sampler quadSampler;
    float2 singleStepOffset = float2(1.0 / float(inputTexture.get_width()), 1.0 / float(inputTexture.get_height()));
    
    // 计算梯度
    float4 topLeft = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate + float2(-singleStepOffset.x, -singleStepOffset.y));
    float4 top = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate + float2(0.0, -singleStepOffset.y));
    float4 topRight = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate + float2(singleStepOffset.x, -singleStepOffset.y));
    float4 left = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate + float2(-singleStepOffset.x, 0.0));
    float4 right = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate + float2(singleStepOffset.x, 0.0));
    float4 bottomLeft = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate + float2(-singleStepOffset.x, singleStepOffset.y));
    float4 bottom = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate + float2(0.0, singleStepOffset.y));
    float4 bottomRight = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate + float2(singleStepOffset.x, singleStepOffset.y));
    
    float gx = -1.0 * topLeft.r + 1.0 * topRight.r - 2.0 * left.r + 2.0 * right.r - 1.0 * bottomLeft.r + 1.0 * bottomRight.r;
    float gy = -1.0 * topLeft.r - 2.0 * top.r - 1.0 * topRight.r + 1.0 * bottomLeft.r + 2.0 * bottom.r + 1.0 * bottomRight.r;
    
    float magnitude = sqrt(gx * gx + gy * gy);
    float direction = atan2(gy, gx);
    
    // 非极大值抑制
    float angle = fmod(direction + M_PI_F, M_PI_F) / M_PI_F * 4.0;
    float r1 = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate + float2(cos(angle) * singleStepOffset.x, sin(angle) * singleStepOffset.y)).r;
    float r2 = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate + float2(-cos(angle) * singleStepOffset.x, -sin(angle) * singleStepOffset.y)).r;
    
    float edge = (magnitude > threshold && magnitude > r1 && magnitude > r2) ? 1.0 : 0.0;
    
    return float4(float3(edge), 1.0);
} 