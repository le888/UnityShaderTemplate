#ifndef _VOLUME_HLSL_
#define _VOLUME_HLSL_

//cloud
//Beer's Law [ exp(-d) ] //d= density or distance
//Powder Effect  [ 1- exp(-d*2) ]


#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
//标准算法
float HenyeyGreenStein(float g,float costh)
{
    return (1.0/(4.0*PI))*((1.0-g*g)/(pow(1.0+g*g-2.0*g*costh,1.5)));
}

//VolumetricRendering.hlsl //unity加速算法 HenyeyGreensteinPhaseFunction
// #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/VolumeRendering.hlsl"


#endif