#ifndef _LIGHTCOMM__
#define _LIGHTCOMM__

//CheapSSS
/**
 * \brief 
 * \param _thickness 厚度，实际是反的，白色代表约投光
 * \param L 光照方向
 * \param N 发现方向
 * \param V 视角方向
 * \param albedo 贴图baseColor
 * \param inDiffuse 漫反射环境光照
 * \param _backB //背光参数 调整法线角度
 * \param _backPower //背光参数 调整背光Power
 * \param _backScale //背光参数 调整背光强度
 * \param lightAttenuation //光照衰减 保函了光照颜色 light.color * light.distanceAttenuation * light.shadowAttenuation;
 * \return
 */
half3 BackLight(half _thickness,half3 L,half3 N,half3 V,half3 albedo,half inDiffuse,half _backB,half _backPower,half _backScale,half3 lightAttenuation)
{
    //背光计算
    float3 backLightDir = normalize(L + N * _backB);
    float bNV = saturate(dot(V,-backLightDir));
    float fLTDot = pow(bNV, _backPower) * _backScale;
    float3 fLT = (fLTDot+inDiffuse) * lightAttenuation * _thickness;
    float3 BlightColor = fLT * albedo;
    return BlightColor;
}
#endif