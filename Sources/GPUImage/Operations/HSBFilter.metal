#include <metal_stdlib>
using namespace metal;

float3 rgb2hsv(float3 c) {
    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    float4 p = mix(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
    float4 q = mix(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

float3 hsv2rgb(float3 c) {
    float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    float3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

fragment float4 hsbFilterFragment(SingleInputVertexIO fragmentInput [[stage_in]],
                                texture2d<float> inputTexture [[texture(0)]],
                                constant float &brightness [[buffer(0)]],
                                constant float &saturation [[buffer(1)]]) {
    constexpr sampler quadSampler;
    float4 textureColor = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate);
    float3 hsv = rgb2hsv(textureColor.rgb);
    
    // 调整亮度
    hsv.z *= brightness;
    
    // 调整饱和度
    hsv.y *= saturation;
    
    float3 rgb = hsv2rgb(hsv);
    return float4(rgb, textureColor.a);
} 