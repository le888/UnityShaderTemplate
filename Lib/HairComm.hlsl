#ifndef HAIR__
#define HAIR__

float3 ShiftTangent(float3 tangent, float3 normal, float3 shift)
{
    float3 shiftedT = tangent + shift*normal;
    return normalize(shiftedT);
}

float3 StrandSpecular(float3 T,float3 V,float3 L,float exponent)
{
    float3 H = normalize(L+V);
    float TdotH = dot(T,H);
    float sinTH = sqrt(1-TdotH*TdotH);
    float dirAtten = smoothstep(-1,0.0,TdotH);
    return dirAtten * pow(sinTH,exponent);
}

sampler2D _ShiftTex;
float _Shift1;
float _Shift2;
float4 _SpecularColor1;
float _SpecularExponent1;
float4 _SpecularColor2;
float _SpecularExponent2;
float _AlphaClip;

float4 HairLighting(float3 tangent,float3 normal,float3 viewVec,float2 uv,float4 albedo,Light light)
{
    float3 lightVec = SafeNormalize(light.direction);
    //shift tangents
    float shiftTex = tex2D(_ShiftTex,uv) - 0.5;
    float3 t1 = ShiftTangent(tangent,normal,_Shift1 + shiftTex);
    float3 t2 = ShiftTangent(tangent,normal,_Shift2 + shiftTex);
    
    //diffuse lighting : the lerp shifts the shadow boundary for a softer look
    // float3 diffuse = saturate(lerp(0.25,1.0,dot(normal,lightVec)));
    float nl = dot(normal,lightVec);
    float3 diffuse = saturate(nl);
    diffuse *= albedo.rgb;
    
    //specular lighting
    float3 specular = _SpecularColor1 * StrandSpecular(t1,viewVec,lightVec,_SpecularExponent1);
    specular += _SpecularColor2 * StrandSpecular(t2,viewVec,lightVec,_SpecularExponent2);
    specular *= nl;
    //final color assembly
    float4 color = float4(0,0,0,albedo.a);

    float radiance = light.color* light.distanceAttenuation* light.shadowAttenuation;
    color.rgb = (diffuse + specular)* radiance ;
    clip(albedo.a -_AlphaClip);
    // color.rgb * ambOcc;
    return color;
}

#endif