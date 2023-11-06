#ifndef _BAKELIGHT_HLSL_
#define _BAKELIGHT_HLSL_
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RealtimeLights.hlsl"

//add value
float3 CheapSSS(half3 N, Light L, half3 V, half fLTDistortion, half fLTScale, half iLTPower, half fLTThickness,
                half3 fLTAmbient, half3 diffuseAlbedo)
{
    half3 vLTLight = L.direction + N * fLTDistortion;
    half fLTDot = pow(saturate(dot(V, -vLTLight)), iLTPower) * fLTScale;
    half3 fLT = L.distanceAttenuation * (fLTDot + fLTAmbient) * fLTThickness;
    return diffuseAlbedo * L.color * fLT;
}

#endif
