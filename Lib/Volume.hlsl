#ifndef _VOLUME_HLSL_
#define _VOLUME_HLSL_

//cloud 发展历程
//step1
//Beer's Law [ exp(-d) ] //d= density or distance 各项同性传播
//Powder Effect  [ 1- exp(-d*2) ]
// HenyeyGreenStein()  //各项异性传播
//########################################################################
//step2
//EA Frostbite engine Dual-Lob Henyey-Greenstein  Dual_Lob_HenyeyGreenstein
//########################################################################
//step3
//Sony Pictures MultipleOctaveScattering()
// 

//加速方法
// sdf,降低分辨率，TAA 

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
//标准算法  光各项异性传播
float HenyeyGreenStein(float g,float costh)
{
    return (1.0/(4.0*PI))*((1.0-g*g)/(pow(1.0+g*g-2.0*g*costh,1.5)));
}

float Dual_Lob_HenyeyGreenstein(float g,float costh,float k)
{
    return lerp(HenyeyGreenStein(g,costh),HenyeyGreenStein(g,costh),k);
}

float MultipleOctaveScattering(float density,float costh,float absorption)
{
    float attenuation = 0.2;
    float contribution = 0.4;
    float phaseAttenuation = 0.1;

    const int scatteringOctaves = 4;
    float a = 1.0;
    float b = 1.0;
    float c = 1.0;
    float g = 0.85;

    float luminance = 0.0;
    [UNITY_LOOP]
    for (int i = 0;i<scatteringOctaves;i++)
    {
        float phaseFunction = HenyeyGreenStein(0.3*c,costh);
        float beers = exp(-density*absorption*a);

        luminance += b*phaseFunction*beers;

        a*= attenuation;
        b*= contribution;
        c*= (1-phaseAttenuation);
    }
    return luminance;
}

//VolumetricRendering.hlsl //unity加速算法 HenyeyGreensteinPhaseFunction
// #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/VolumeRendering.hlsl"


#endif