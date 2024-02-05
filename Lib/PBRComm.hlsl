#ifndef _PBRCOMM_
#define _PBRCOMM_

#ifndef PI
#define PI 3.14159265358979323846
#endif

#ifndef HALF_MIN
#define HALF_MIN 6.103515625e-5  // 2^-14, the same value for 10, 11 and 16-bit: https://www.khronos.org/opengl/wiki/Small_Float_Formats
#endif

#ifndef HALF_MIN_SQRT
#define HALF_MIN_SQRT 0.0078125  // 2^-7 == sqrt(HALF_MIN), useful for ensuring HALF_MIN after x^2
#endif


/////////////////////diffuse//////////////////
float OrenNayarDiffuse(
    float3 lightDirection,
    float3 viewDirection,
    float3 surfaceNormal,
    float roughness,
    float albedo)
{
    float LdotV = dot(lightDirection, viewDirection);
    float NdotL = dot(lightDirection, surfaceNormal);
    float NdotV = dot(surfaceNormal, viewDirection);

    float s = LdotV - NdotL * NdotV;
    float t = lerp(1.0, max(NdotL, NdotV), step(0.0, s));

    float sigma2 = roughness * roughness;
    float A = 1.0 + sigma2 * (albedo / (sigma2 + 0.13) + 0.5 / (sigma2 + 0.33));
    float B = 0.45 * sigma2 / (sigma2 + 0.09);

    return albedo * max(0.0, NdotL) * (A + B * s / t) / PI;
}

/////////////////DFG/////////////////////
//Cook-Torrance BRDF

//D
//Trowbridge-Reitz GGX
float D_GGX(float3 N, float3 H, float Roughness)
{
    float a = max(0.001, Roughness * Roughness);
    float a2 = a * a;
    float NdotH = saturate(dot(N, H));
    float NdotH2 = NdotH * NdotH;
    float nom = a2;
    float denom = (NdotH2 * (a2 - 1.0) + 1.0);
    denom = PI * denom * denom;
    return nom / max(denom, 0.001); //防止分母为0
}

float D_GGXAniso(float ax, float ay, float NoH, float3 H, float3 X, float3 Y)
{
    float XoH = dot(X, H);
    float YoH = dot(Y, H);
    float d = XoH * XoH / (ax * ax) + YoH * YoH / (ay * ay) + NoH * NoH;
    return 1 / (PI * ax * ay * d * d);
}

float D_Charlie_C(float roughness, float NoH)
{
    // Estevez and Kulla 2017, "Production Friendly Microfacet Sheen BRDF"
    float invAlpha = 1.0 / roughness;
    float cos2h = NoH * NoH;
    float sin2h = max(1.0 - cos2h, 0.0078125); // 2^(-14/2), so sin2h^2 > 0 in fp16
    return (2.0 + invAlpha) * pow(sin2h, invAlpha * 0.5) / (2.0 * PI);
}

//Schlick Fresnel direct
float3 F_Schlickss(float3 F0, float3 N, float3 V)
{
    float VdotH = saturate(dot(V, N));
    return F0 + (1.0 - F0) * pow(1.0 - VdotH, 5.0);
}

//UE4 Black Ops II modify version
float2 EnvBRDFApprox(float Roughness, float NV)
{
    // [ Lazarov 2013, "Getting More Physical in Call of Duty: Black Ops II" ]
    // Adaptation to fit our G term.
    const float4 c0 = {-1, -0.0275, -0.572, 0.022};
    const float4 c1 = {1, 0.0425, 1.04, -0.04};
    float4 r = Roughness * c0 + c1;
    float a004 = min(r.x * r.x, exp2(-9.28 * NV)) * r.x + r.y;
    float2 AB = float2(-1.04, 1.04) * a004 + r.zw;
    return AB;
}

float GeometrySchlickGGX(float NdotV, float roughness)
{
    float r = (roughness + 1.0);
    float k = (r * r) / 8.0;

    float nom = NdotV;
    float denom = NdotV * (1.0 - k) + k;

    return nom / denom;
}

float GeometrySmith(float3 N, float3 V, float3 L, float roughness)
{
    float NdotV = max(dot(N, V), 0.0);
    float NdotL = max(dot(N, L), 0.0);
    float ggx1 = GeometrySchlickGGX(NdotV, roughness);
    float ggx2 = GeometrySchlickGGX(NdotL, roughness);

    return ggx1 * ggx2;
}


//////////////////////////indrect/////////////////////////
float3 fresnelSchlickRoughness(float cosTheta, float3 F0, float roughness)
{
    float r = 1.0 - roughness;
    return F0 + (max(r.xxx, F0) - F0) * pow(1.0 - cosTheta, 5.0);
}

float GeometrySchlickGGXInderect(float NdotV, float roughness)
{
    float a = roughness;
    float k = (a * a) / 2.0;

    float nom = NdotV;
    float denom = NdotV * (1.0 - k) + k;

    return nom / denom;
}

float GeometrySmithInderect(float N, float V, float L, float roughness)
{
    float NdotV = max(dot(N, V), 0.0);
    float NdotL = max(dot(N, L), 0.0);
    float ggx2 = GeometrySchlickGGXInderect(NdotV, roughness);
    float ggx1 = GeometrySchlickGGXInderect(NdotL, roughness);

    return ggx1 * ggx2;
}

float3 DirectCookTorranceOnlySpecular(float3 N, float3 V, float3 L, float3 F0, float roughness)
{
    float3 H = normalize(V + L);
    float NdotL = max(dot(N, L), 0.0);
    float NdotV = max(dot(N, V), 0.0);
    float VdotH = max(dot(V, H), 0.0);

    float3 F = F_Schlickss(VdotH, F0, roughness);
    float G = GeometrySmith(N, V, L, roughness);
    float D = D_GGX(N, H, roughness);

    float3 nominator = F * G * D;
    float denominator = 4.0 * (NdotL * NdotV) + 0.001; //防止分母为0
    float3 specular = nominator / denominator;
    return specular;
}

//Cook-Torrance BRDF
float3 DirectCookTorranceBRDF(float3 N, float3 V, float3 L, float3 F0, float roughness, float metallic, float3 albedo,
                              float3 lightRadiance)
{
    float3 H = normalize(V + L);
    float NdotL = max(dot(N, L), 0.0);
    float NdotV = max(dot(N, V), 0.0);
    float NdotH = max(dot(N, H), 0.0);
    float VdotH = max(dot(V, H), 0.0);

    float3 F = F_Schlickss(VdotH, F0, roughness);
    float G = GeometrySmith(N, V, L, roughness);
    float D = D_GGX(N, H, roughness);

    float3 nominator = F * G * D;
    float denominator = 4.0 * (NdotL * NdotV) + 0.001; //防止分母为0
    float3 specular = nominator / denominator;

    float3 kS = F;
    float3 kD = 1.0 - kS;
    kD *= 1.0 - metallic;

    float3 irradiance = NdotL * albedo;
    float3 diffuse = irradiance * kD / PI;
    return (diffuse + specular) * lightRadiance * NdotL;
}

/**
 * \brief WaterSSR
 * \param
 * \param  
 * \return
 */

//screenPixelNdcZ xy: screenPixel z:ndcZ
void GetScreenInfo(float4 positionCS,out float3 screenPixelNdcZ)
{
    positionCS.y *= _ProjectionParams.x;
    positionCS.xyz /= positionCS.w;//ndc
    positionCS.xy = positionCS*0.5+0.5;//xy [-1,1] z:[1,0]
    // return float4( positionCS.xy,0,0);
    screenPixelNdcZ.xyz = positionCS.xyz;// NDC空间坐标
}


TEXTURE2D(_CameraOpaqueTexture);SAMPLER(sampler_CameraOpaqueTexture);
TEXTURE2D(_CameraDepthTexture);SAMPLER(sampler_CameraDepthTexture);

float GetDepth(float2 uv)
{
    return SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, uv).r;
}

float4 GetSceneColor(float2 uv)
{
    return SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_CameraOpaqueTexture,uv);
}

float4 WaterSSR(float3 positionWS, float3 waterNormal,float3 _PlayerPosition)
{
    float3 V = (GetWorldSpaceViewDir(positionWS));
    float4 positionCS = TransformWorldToHClip(positionWS);

    float SSRLength = 15;
    float FarSSRLength = 50;
    float MaxLingearStep = 32;

    float3 reflectDir = reflect(-V, waterNormal);
    float3 endWS = positionWS + reflectDir * SSRLength;
    float4 endPositionCS = TransformWorldToHClip(endWS);

    float3 farWS = positionWS + reflectDir * FarSSRLength;
    float4 farPositionCS = TransformWorldToHClip(farWS);

    float3 begin_ScreenPixelNdcZ, end_ScreenPixelNdcZ, far_ScreenPixelNdcZ;

    GetScreenInfo(positionCS, begin_ScreenPixelNdcZ);
    GetScreenInfo(endPositionCS, end_ScreenPixelNdcZ);
    GetScreenInfo(farPositionCS, far_ScreenPixelNdcZ);
    // return  begin_ScreenPixelNdcZ.z;
    // return end_ScreenPixelNdcZ.z;

    float3 Step = (end_ScreenPixelNdcZ - begin_ScreenPixelNdcZ) / MaxLingearStep;
    float3 Ray = begin_ScreenPixelNdcZ;
    bool isHit = false;
    float2 hitUV = (float2)0;

    float LastDepth = Ray.z;

    float4 SSRColor = 0;
    //远处的反射 RayMarch 无法Hit到
    // float isFar = 1;
    float isFar = 0;

    float fade = pow(1 - dot(normalize(V), waterNormal), 5); //fresnel


    // 最远端在相机视口内
    UNITY_BRANCH if ((far_ScreenPixelNdcZ).y < 1)
    {
        float farDepth = GetDepth(far_ScreenPixelNdcZ.xy);

        farDepth = LinearEyeDepth(farDepth, _ZBufferParams);

        float playViewDepth = mul(unity_WorldToCamera, float4(_PlayerPosition.xyz, 1));

        //如果farDepth与玩家太近，那么丢弃该反射
        UNITY_BRANCH if (abs(playViewDepth - farDepth) > SSRLength)
        {
            // SSRColor =  GetSceneColor(far_ScreenPixelNdcZ.xy)*fade*float4(1,0,0,0);
            SSRColor = GetSceneColor(far_ScreenPixelNdcZ.xy) * fade;
        }
        else
        {
            SSRColor.w = 1;
        }
    }
    // return  SSRColor;


    float3 lastRay = Ray;
    UNITY_LOOP
    for (int n = 1; n < MaxLingearStep; n++)
    {
        Ray += Step;
        //如果测试点跑到 视口外面去了，那么停止for循环
        UNITY_BRANCH if (Ray.z < 0 || Ray.z > 1 || Ray.x < 0 || Ray.x > 1 || Ray.y < 0 || Ray.y > 1)
        {
            break;
        }

        float Depth = GetDepth(Ray.xy);

        //  上一次深度<Depth<这一次深度
        // if(Depth + _PerPixelCompareBias >Ray.z && Ray.z <Depth +_PerPixelDepthBias )
        if (Ray.z < Depth && Depth < LastDepth)
        {
            isHit = true;
            // hitUV = Ray.xy;
            //插值uv
            float t = (Depth - Ray.z) / (LastDepth - Ray.z);
            hitUV = lerp(Ray.xy, lastRay.xy, t);
            // (Ray.z - lastRay.z)
            break;
        }
        LastDepth = Ray.z;
        lastRay = Ray;
    }

    if (isHit)
    {
        SSRColor = GetSceneColor(hitUV) * fade;
    }
    return SSRColor;
}
#endif
