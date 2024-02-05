#ifndef _TASKIN_
#define _TASKIN_

#include "PBRComm.hlsl"
//////////////////////////////////////////////////benckman///////////////////////////////////////////
float PHBeckmann(float ndoth, float m)
{
    float alpha = acos(ndoth);
    float ta = tan(alpha);
    float val = 1.0 / (m * m * pow(ndoth, 4.0)) * exp(-(ta * ta) / (m * m));
    return val;
} // Render a screen-aligned quad to precompute a 512x512 texture.
float KSTextureCompute(float2 tex : TEXCOORD0)
{
    // Scale the value to fit within [0,1] – invert upon lookup.
    return 0.5 * pow(PHBeckmann(tex.x, tex.y), 0.1);
}


float KS_Skin_Specular(
    float3 N, // Bumped surface normal
    float3 L, // Points to light
    float3 V, // Points to eye
    float m, // Roughness
    float rho_s// Specular brightness
    //sampler2D beckmannTex
)
{
    float result = 0.0;
    float ndotl = dot(N, L);
    if (ndotl > 0.0)
    {
        float3 h = L + V; // Unnormalized half-way vector
        float3 H = normalize(h);

        float ndoth = saturate(dot(N, H));
        // float PH = pow(2.0 * tex2D(beckmannTex, float2(ndoth, m)), 10.0);
        float PH = pow(2.0 * KSTextureCompute(float2(ndoth, m)), 10.0);
        float F = F_Schlickss(0.028,N, V);
        float frSpec = max(PH * F / dot(h, h), 0);
        result = ndotl * rho_s * frSpec; // BRDF * dot(N,L) * rho_s
    }
    return result;
}

//////////////////////////////////////////////////benckman end///////////////////////////////////////////

//////////////////////////////////PreIntegratedSkin////////////////////////////////////
///近似拟合 Lut
float3 PreIntegratedSkinWithCurveApprox(half NdotL, half curvature)
{
    // NdotL = mad(NdotL, 0.5, 0.5); // map to 0 to 1 range
    float curva = (1.0 / mad(curvature, 0.5 - 0.0625, 0.0625) - 2.0) / (16.0 - 2.0);
    // curvature is within [0, 1] remap to normalized r from 2 to 16
    float oneMinusCurva = 1.0 - curva;
    float3 curve0;
    {
        float3 rangeMin = float3(0.0, 0.3, 0.3);
        float3 rangeMax = float3(1.0, 0.7, 0.7);
        float3 offset = float3(0.0, 0.06, 0.06);
        float3 t = saturate(mad(NdotL, 1.0 / (rangeMax - rangeMin),
                                (offset + rangeMin) / (rangeMin - rangeMax)));
        float3 lowerLine = (t * t) * float3(0.65, 0.5, 0.9);
        lowerLine.r += 0.045;
        lowerLine.b *= t.b;
        float3 m = float3(1.75, 2.0, 1.97);
        float3 upperLine = mad(NdotL, m, float3(0.99, 0.99, 0.99) - m);
        upperLine = saturate(upperLine);
        float3 lerpMin = float3(0.0, 0.35, 0.35);
        float3 lerpMax = float3(1.0, 0.7, 0.6);
        float3 lerpT = saturate(mad(NdotL, 1.0 / (lerpMax - lerpMin), lerpMin / (lerpMin - lerpMax)));
        curve0 = lerp(lowerLine, upperLine, lerpT * lerpT);
    }
    float3 curve1;
    {
        float3 m = float3(1.95, 2.0, 2.0);
        float3 upperLine = mad(NdotL, m, float3(0.99, 0.99, 1.0) - m);
        curve1 = saturate(upperLine);
    }
    float oneMinusCurva2 = oneMinusCurva * oneMinusCurva;
    float3 brdf = lerp(curve0, curve1, mad(oneMinusCurva2, -1.0 * oneMinusCurva2, 1.0));
    return brdf;
}

//////////////////////////////////PreIntegratedSkin////////////////////////////
#endif
