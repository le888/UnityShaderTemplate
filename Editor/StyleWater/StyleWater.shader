// This shader fills the mesh shape with a color predefined in the code.
Shader "Custom/StyleWater"
{
    // The properties block of the Unity shader. In this example this block is empty
    // because the output color is predefined in the fragment shader code.
    Properties
    {
        [KeywordEnum(None,Diffuse,Specular,Caustic,Foam,Cloud,CheapSSS,SSR,fresnel)]_Debug("Debug", Float) = 0

        [Main(BaseInfoGroup,_,off,off)]
        _EnableBase("Enable Base",Float) =1
        [Sub(BaseInfoGroup)]_ShallowDistance("ShallowDistance", Float) = 5
        [Sub(BaseInfoGroup)]_DeepDistance("DeepDistance", Float) = 5
        [Sub(BaseInfoGroup)]_Density("Density", Range(0,1)) = 0.5
        [Sub(BaseInfoGroup)][HDR]_shallowColor("shallowColor", Color) = (1,1,1,1)
        [Sub(BaseInfoGroup)][HDR]_deepColor("deepColor", Color) = (1,1,1,1)
        [Sub(BaseInfoGroup)]_WinDirection("WinDirection x z",Vector)=(1,0,0,0)
        [Sub(BaseInfoGroup)]_FresnelPower("FresnelPower", float) = 5
        //        [Sub(BaseInfoGroup)]_FresnelIntensity("FresnelIntensity", Range(0,1)) = 1

        [Main(NormalGroup,_,off,off)]
        _NormalGroup("NormalGroup",Float) =0
        [Tex(NormalGroup)][Normal]_BumpMap("Normal (RGB)", 2D) = "bump" {}
        [Tex(NormalGroup)][Normal]_DetailNormalMap("DetailNormalMap (RGB)", 2D) = "bump" {}
        [Tex(NormalGroup)]_NoiseMap("NoiseMap", 2D) = "white" {}

        [Sub(NormalGroup)]_NormalMapIntensity("NormalMapIntensity",Range(0,1)) = 0.5
        [Sub(NormalGroup)]_Smoothness("Smoothness", Range(0,1)) = 0.5
        [Sub(NormalGroup)]_DiffuseIntensity("DiffuseIntensity", Range(0,1)) = 0.5
        [Sub(NormalGroup)]_SpecularIntensity("SpecularIntensity", Range(0,1)) = 0.5


        [Main(CausticGroup,USE_CAUSTIC,off,on)]
        USE_CAUSTIC("Enable Caustic",Float) =1
        [Tex(CausticGroup)]_CausticMap("CausticMap", 2D) = "black" {}

        [Main(CubeMapGroup,USE_CUBEMAP,off,on)]
        USE_CUBEMAP("Enable CubeMap",Float) =1
        [Sub(CubeMapGroup)]_CubeMapIntensity("CubeMapIntensity", Range(0,1)) = 1

        [Main(FoamGroup,USE_FOAM,off,on)]
        USE_FOAM("Enable Foam",Float) =0
        [Sub(FoamGroup)]_FoamWidth("Foam Width",Range(0,1)) = 0.95
        [Sub(FoamGroup)]_FoamSpeed("Foam Speed",Float) = 1

        [Main(CloudGroup,USE_CLOUD,off,on)]
        USE_CLOUD("Enable Cloud",Float) =0
        [Tex(CloudGroup)]_CloudMap ("Cloud Map", 2D) = "black" {}
        [Sub(CloudGroup)]_CloudMap_ST("Cloud Map ST",Vector)=(1,1,0,0)

        [Sub(CloudGroup)]_CloudIntensity("Cloud Intensity",Range(0,1)) = 0.5
        [Sub(CloudGroup)]_CloudMoveSpeed("Cloud Move Speed",Float) = 0.1
        [Sub(CloudGroup)]_CloudColor("Cloud Color",Color) =(1,1,1,1)
        [Sub(CloudGroup)]_WindDirection("Wind Direction",Vector)=(1,0,0,0)

        [Main(CheapSSSGroup,USE_CHEAPSSS,off,on)]
        USE_CHEAPSSS("Enable CheapSSS",Float) =0
        [Sub(CheapSSSGroup)][HDR]_SSSColor("SSS Color",Color) = (0.2,0.2,0.2,1)
        [Sub(CheapSSSGroup)]_SSSDistance("_SSSDistance",Range(0,1)) = 0.5
        [Sub(CheapSSSGroup)]_SSSExp("_SSSExp",Range(0,1)) = 1
        [Sub(CheapSSSGroup)]_SSSIntensity("_SSSIntensity",Range(0,10)) = 1

        [Main(SSRGroup,USE_SSR,off,on)]
        USE_SSR("Enable SSR",Float) =0
        [Sub(SSRGroup)]_SSRMaxSampleCount ("SSR Max Sample Count", Range(0, 64)) =32
        [Sub(SSRGroup)]_SSRSampleStep ("SSR Sample Step", Range(4, 32)) = 4
        [Sub(SSRGroup)]_SSRIntensity ("SSR Intensity", Range(0, 2)) = 1
        [Sub(SSRGroup)]_SSRNormalDistortion("SSR Normal Distortion",Range(0,1)) = 0.15
        [Sub(SSRGroup)]_SSPRDistortion("SSPR Distortion",Float) = 1


        [Main(ShadowGroup,USE_SHADOW,off,on)]
        USE_SHADOW("Receive Shadow",Float) =0
        [Sub(ShadowGroup)]_ShadowIntensity("Shadowm Intensity",Range(0,1)) = 0.8

        [Main(CustomLightGroup,USE_CUSTOM_LIGHT_DIR,off,on)]
        USE_CUSTOM_LIGHT_DIR("Enable Custom Light Dir",Float) =0
        [Sub(CustomLightGroup)]_CustomLightDir("Custom Light Dir",Vector)=(1,0,0,0)
    }

    // The SubShader block containing the Shader code.
    SubShader
    {
        // SubShader Tags define when and under which conditions a SubShader block or
        // a pass is executed.
        Tags
        {
            "RenderType" = "Transparent" "Queue" = "Transparent" "RenderPipeline" = "UniversalPipeline"

        }

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            //            ZWrite On
            //            Cull Back
            // The HLSL code block. Unity SRP uses the HLSL language.
            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/EntityLighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ImageBasedLighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RealtimeLights.hlsl"
            // #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/GlobalIllumination.hlsl"


            #pragma shader_feature _DEBUG_NONE _DEBUG_DIFFUSE _DEBUG_SPECULAR _DEBUG_CAUSTIC _DEBUG_FOAM _DEBUG_CLOUD _DEBUG_CHEAPSSS _DEBUG_SSR _DEBUG_FRESNEL
            #pragma shader_feature _ USE_CAUSTIC
            #pragma shader_feature _ USE_FOAM
            #pragma shader_feature _ USE_CHEAPSSS
            #pragma shader_feature _ USE_CLOUD
            #pragma shader_feature _ USE_SHADOW
            #pragma shader_feature _ USE_SSR
            #pragma shader_feature _ USE_CUBEMAP
            #pragma shader_feature _ USE_CUSTOM_LIGHT_DIR


            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fog

            TEXTURE2D(_NoiseMap);
            SAMPLER(sampler_NoiseMap);

            TEXTURE2D(_BumpMap);
            SAMPLER(sampler_BumpMap);

            TEXTURE2D(_DetailNormalMap);
            SAMPLER(sampler_DetailNormalMap);

            TEXTURE2D(_CausticMap);
            SAMPLER(sampler_CausticMap);

            TEXTURE2D(_CloudMap);
            SAMPLER(sampler_CloudMap);

            TEXTURE2D(_CameraOpaqueTexture);
            SAMPLER(sampler_CameraOpaqueTexture);
            TEXTURE2D(_CameraDepthTexture);
            SAMPLER(sampler_CameraDepthTexture);


            CBUFFER_START(UnityPerMaterial)
                half _Smoothness;


                half _DiffuseIntensity;
                half _SpecularIntensity;
                half _NormalMapIntensity;


                half _ShallowDistance;
                half _DeepDistance;
                half _Density;
                half4 _shallowColor;
                half4 _deepColor;
                half4 _WinDirection;
                half _FresnelPower;
                // half _FresnelIntensity;

                half _CubeMapIntensity;

                half _FoamWidth;
                half _FoamSpeed;

                half _CloudIntensity;
                half _CloudMoveSpeed;
                half4 _CloudColor;
                half4 _WindDirection;
                half4 _CloudMap_ST;


                half _SSSDistance;
                half _SSSExp;
                half _SSSIntensity;
                half4 _SSSColor;

                half _SSRIntensity;
                half _SSRNormalDistortion;
                half _SSPRDistortion;
                half _SSRMaxSampleCount;
                half _SSRSampleStep;


                half _ShadowIntensity;

                half4 _CustomLightDir;

            CBUFFER_END

            float4 _PlayerPosition = float4(0, 0, 0, 1); // player position in world space
            //Physically based Shading

            // This line defines the name of the vertex shader.
            #pragma vertex vert
            // This line defines the name of the fragment shader.
            #pragma fragment frag

            // The Core.hlsl file contains definitions of frequently used HLSL
            // macros and functions, and also contains #include references to other
            // HLSL files (for example, Common.hlsl, SpaceTransforms.hlsl, etc.).
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"


            #pragma shader_feature _DEBUG_NONE _DEBUG_ALBODE
            // The structure definition defines which variables it contains.
            // This example uses the Attributes structure as an input structure in
            // the vertex shader.
            struct Attributes
            {
                // The positionOS variable contains the vertex positions in object
                // space.
                float4 positionOS : POSITION;
                half3 normalOS : NORMAL;
                half2 uv : TEXCOORD0;
                half3 tangentOS : TANGENT;
                // float3 tangent : TANGENT;
            };

            struct Varyings
            {
                // The positions in this struct must have the SV_POSITION semantic.
                float4 positionHCS : SV_POSITION;
                half3 normalWS : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                half2 uv : TEXCOORD2;
                half3 tangentWS : TEXCOORD3;
                float4 positionNDC : TEXCOORD4;
            };


            // //利用cos生成的渐变色，使用网站：https://sp4ghet.github.io/grad/
            // half4 cosine_gradient(float x, half4 phase, half4 amp, half4 freq, half4 offset)
            // {
            //     float TAU = 2. * 3.14159265;
            //     phase *= TAU;
            //     x *= TAU;
            //
            //     return half4(
            //         offset.r + amp.r * 0.5 * cos(x * freq.r + phase.r) + 0.5,
            //         offset.g + amp.g * 0.5 * cos(x * freq.g + phase.g) + 0.5,
            //         offset.b + amp.b * 0.5 * cos(x * freq.b + phase.b) + 0.5,
            //         offset.a + amp.a * 0.5 * cos(x * freq.a + phase.a) + 0.5
            //     );
            // }

            half CheapSSS(float3 N, float3 L, float3 V, float SSSDistance, float SSSExp, float SSSIntensity)
            {
                half3 fakeN = -normalize(lerp(N, L, SSSDistance));
                half sss = SSSIntensity * pow(saturate(dot(fakeN, V)), SSSExp);
                return max(0, sss);
            }


            void GetScreenInfo(float4 positionCS, out float3 screenPixelNdcZ)
            {
                positionCS.y *= _ProjectionParams.x;
                positionCS.xyz /= positionCS.w; //ndc
                positionCS.xy = positionCS * 0.5 + 0.5; //xy [-1,1] z:[1,0]
                // return float4( positionCS.xy,0,0);
                screenPixelNdcZ.xyz = positionCS.xyz; // NDC空间坐标
            }

            float GetDepth(half2 uv)
            {
                return SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, uv).r;
            }

            float4 GetSceneColor(half2 uv)
            {
                return SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, uv);
            }

            bool IsInClipView(float3 Ray)
            {
                if (Ray.z < 0 || Ray.z > 1 || Ray.x < 0 || Ray.x > 1 || Ray.y < 0 || Ray.y > 1)
                {
                    return false;
                }
                return true;
            }


            float4 WaterSSR(float3 positionWS, float3 waterNormal = float3(0, 1, 0))
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

                half4 SSRColor = half4(0, 0, 0, 1);
                //远处的反射 RayMarch 无法Hit到
                // float isFar = 1;
                float isFar = 0;

                float fade = pow(1 - dot(normalize(V), waterNormal), 5); //fresnel


                // 最远端在相机视口内
                UNITY_BRANCH if ((far_ScreenPixelNdcZ).y < 1)
                {
                    float farDepth = GetDepth(far_ScreenPixelNdcZ.xy);

                    farDepth = LinearEyeDepth(farDepth, _ZBufferParams);

                    //  float playViewDepth = mul(unity_WorldToCamera,float4(_PlayerPosition.xyz,1));
                    //
                    //  //如果farDepth与玩家太近，那么丢弃该反射
                    // UNITY_BRANCH if(abs(playViewDepth-farDepth)>SSRLength)
                    //  {
                    //      // SSRColor =  GetSceneColor(far_ScreenPixelNdcZ.xy)*fade*float4(1,0,0,0);
                    //      SSRColor =  GetSceneColor(far_ScreenPixelNdcZ.xy)*fade;
                    //  }
                    //  else
                    //  {
                    //      SSRColor.w =1;
                    //  }
                }
                // return  SSRColor;


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
                        hitUV = Ray.xy;
                        break;
                    }
                    LastDepth = Ray.z;
                }

                if (isHit)
                {
                    SSRColor = GetSceneColor(hitUV) * fade;
                }
                return SSRColor;
            }


            half DirectBRDFSpecularCoustom(half smoothness,half3 normalWS, half3 lightDirectionWS, half3 viewDirectionWS)
            {
                float3 lightDirectionWSFloat3 = float3(lightDirectionWS);
                float3 halfDir = SafeNormalize(lightDirectionWSFloat3 + float3(viewDirectionWS));

                float NoH = saturate(dot(float3(normalWS), halfDir));
                half LoH = half(saturate(dot(lightDirectionWSFloat3, halfDir)));

                // GGX Distribution multiplied by combined approximation of Visibility and Fresnel
                // BRDFspec = (D * V * F) / 4.0
                // D = roughness^2 / ( NoH^2 * (roughness^2 - 1) + 1 )^2
                // V * F = 1.0 / ( LoH^2 * (roughness + 0.5) )
                // See "Optimizing PBR for Mobile" from Siggraph 2015 moving mobile graphics course
                // https://community.arm.com/events/1155

                // Final BRDFspec = roughness^2 / ( NoH^2 * (roughness^2 - 1) + 1 )^2 * (LoH^2 * (roughness + 0.5) * 4.0)
                // We further optimize a few light invariant terms
                // brdfData.normalizationTerm = (roughness + 0.5) * 4.0 rewritten as roughness * 4.0 + 2.0 to a fit a MAD.
                half perceptualRoughness = PerceptualSmoothnessToPerceptualRoughness(smoothness);
                half roughness           = max(PerceptualRoughnessToRoughness(perceptualRoughness), HALF_MIN_SQRT);
                half roughness2          = max(roughness * roughness, HALF_MIN);
                half roughness2MinusOne = roughness2 - half(1.0);
                half normalizationTerm   = roughness * half(4.0) + half(2.0);
                float d = NoH * NoH * roughness2MinusOne + 1.00001f;

                half LoH2 = LoH * LoH;
                half specularTerm = roughness2 / ((d * d) * max(0.1h, LoH2) * normalizationTerm);

                // On platforms where half actually means something, the denominator has a risk of overflow
                // clamp below was added specifically to "fix" that, but dx compiler (we convert bytecode to metal/gles)
                // sees that specularTerm have only non-negative terms, so it skips max(0,..) in clamp (leaving only min(100,...))
            #if defined (SHADER_API_MOBILE) || defined (SHADER_API_SWITCH)
                specularTerm = specularTerm - HALF_MIN;
                specularTerm = clamp(specularTerm, 0.0, 100.0); // Prevent FP16 overflow on mobiles
            #endif

            return specularTerm;
            }
            


            // The vertex shader definition with properties defined in the Varyings
            // structure. The type of the vert function must match the type (struct)
            // that it returns.
            Varyings vert(Attributes IN)
            {
                // Declaring the output object (OUT) with the Varyings struct.
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);

                float3 positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.positionWS = positionWS;
                OUT.tangentWS = TransformObjectToWorldDir(IN.tangentOS);
                OUT.uv = IN.uv;


                half4 ndc = OUT.positionHCS * 0.5;
                OUT.positionNDC.xy = float2(ndc.x, ndc.y * _ProjectionParams.x) + ndc.w;
                //  (-w < x(-y) < w --> 0 < xy < w)
                OUT.positionNDC.zw = OUT.positionHCS.zw;

                return OUT;
            }

            // The fragment shader definition.
            half4 frag(Varyings data) : SV_Target
            {
                float4 shadowCoord = TransformWorldToShadowCoord(data.positionWS);
                Light light = GetMainLight(shadowCoord);
                half3 L = SafeNormalize(light.direction);

                #ifdef USE_CUSTOM_LIGHT_DIR
                L = SafeNormalize(_CustomLightDir.xyz);
                #endif


                half3 N = SafeNormalize(data.normalWS);
                half3 T = SafeNormalize(data.tangentWS);
                half3 B = cross(N, T);
                half3x3 TBN = float3x3(T, B, N);
                // half3 n = SafeNormalize(UnpackNormal(tex2D(_BumpMap, data.uv)));
                // n = mul(n, TBN);


                half3 V = GetWorldSpaceNormalizeViewDir(data.positionWS);
                // half3 H = SafeNormalize(L + V);
                // half nv = saturate(dot(n, V));
                // half nl = saturate(dot(n, L));

                ////////////////Lighting/////////////////////
                half LightLum = Luminance(light.color);

                half4 finalColor = 0;
                ///////////Depth Fade 根据深度进行颜色变换////////////////
                half2 screenUV = data.positionNDC.xy / data.positionNDC.w;
                float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, screenUV);
                float3 depthWorldPosition = ComputeWorldSpacePosition(screenUV, depth, UNITY_MATRIX_I_VP);

                float depthDistance = length(depthWorldPosition - data.positionWS);
                half depthFade = saturate(depthDistance / _DeepDistance);
                finalColor = lerp(_shallowColor, _deepColor, depthFade);
                // return depthFade;
                //////////////////////////

                // return finllyColor;
                //===================== Refraction  扭曲 =======================================================================
                half2 offSetUV = _Time.x * _WinDirection.xz;
                half4 noise = SAMPLE_TEXTURE2D(_NoiseMap, sampler_NoiseMap, data.positionWS.xz*0.1 + offSetUV);
                //float2(-_Time.x*0.5,0));
                // return noise;
                //用噪音扰动NormalMap消除Tilling感

                //float2(_Time.x*0.5,0)
                half3 normalMap = UnpackNormal(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap,
                    data.positionWS.xz *0.025 + offSetUV + noise*0.02));


                half offSetUVDetail = _Time.x * _WinDirection.xz * 0.7;
                // half offSetUVDetail =float2(-_Time.x*0.3,0);
                //
                half3 normalDetailMap = UnpackNormal(SAMPLE_TEXTURE2D(_DetailNormalMap, sampler_DetailNormalMap,
                    data.positionWS.xz + offSetUVDetail -noise*0.02));
                // normalDetailMap.xyz = normalDetailMap.xyz * 2 - 1;
                
                // normalMap = lerp(normalMap, normalDetailMap, 0.5);
                // normalMap = normalize(normalMap);
                //水面TBN固定 N=float3(0,1,0)
                normalMap = mul(normalMap, TBN);
                // return half4(0,1,0,1);
                 // return half4(normalMap,1);

                half2 distortionUV = (noise * 2 - 1) * 0.01 * 2;
                half4 sceneColor = SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_CameraOpaqueTexture,
                    screenUV +distortionUV);
                half distortionDistanceFade = saturate(depthDistance / _ShallowDistance);
                finalColor = lerp(sceneColor, lerp(sceneColor, finalColor, _Density), distortionDistanceFade);

                half alpha = saturate(depthDistance / 1); //saturate(distortionDistanceFade+depthFade);
                alpha = saturate(pow(alpha, 2));
                // return alpha;
                half shadow = 1;
                #ifdef USE_SHADOW
                    shadow = lerp(_ShadowIntensity,1, light.shadowAttenuation);
                 
                #endif

                //===================== Diffuse 漫反射 =======================================================================
                normalMap = normalize(normalMap);
                // return half4(normalMap,1);
                N = normalize(lerp(float3(0, 1, 0), normalMap, _NormalMapIntensity));
                half NL = dot(N, L);
                half NL01 = NL * 0.5 + 0.5;
                half diffuse = lerp(0.25, 1.2, NL01);
                finalColor *= diffuse * LightLum * _DiffuseIntensity;

                #ifdef _DEBUG_DIFFUSE
                return diffuse * LightLum * _DiffuseIntensity;
                #endif

                // return finalColor;

                V = normalize(V);
                half3 R = reflect(-V, normalize(lerp(half3(0, 1, 0), normalMap, 0.15)));
                float4 fresnel = saturate(pow(1 - V.y, _FresnelPower));

                //===================== Specular 高光 =======================================================================
                // float3 N_Specular = lerp(float3(0,1,0),normalMap,0.1);
                // return N.xyzz;
                // half3 H = normalize(L + V);
                // half NH = saturate(dot(N, H));
                // return N.xyzz;
                // return NH;

                // half smoothness = exp2(10 * _Smoothness + 1);
                //
                // half specular = saturate(pow(NH, smoothness));
                // finalColor.xyz += LightingSpecular(light.color,L,normalMap,V,finalColor,_Smoothness);
                // return specular;
                half3 specularColor = DirectBRDFSpecularCoustom(_Smoothness,N,L,V) * kDieletricSpec.rgb;//specular * light.color.xyzz * shadow * fresnel * _SpecularIntensity * 100;
                finalColor.xyz += specularColor;

                // return finalColor;
                #ifdef _DEBUG_SPECULAR
                return half4(specularColor.xyz,1);
                #endif


                //===================== Caustic 模拟焦散 =======================================================================
                //用深度图的世界坐标采样 CausticMap 模拟其在水中晃动的感觉
                //贴图焦散
                #ifdef USE_CAUSTIC
                half4 caustic = SAMPLE_TEXTURE2D(_CausticMap, sampler_CausticMap,depthWorldPosition.xz*0.2+distortionUV*5);
                caustic *= 1 - distortionDistanceFade;
                finalColor += caustic * 0.3 * LightLum;
                #ifdef _DEBUG_CAUSTIC
                return caustic * 0.3 * LightLum;
                #endif

                // return finalColor;
                #endif

                half3 viewDire = TransformWorldToViewDir(V);
                // half viewMask = smoothstep(0.3,1,abs(viewDire.x));
                half viewMask = pow(abs(viewDire.x), 5);
                // return viewMask;
                //===================== Foam 边缘水花=======================================================================
                #ifdef USE_FOAM
                // return _NoiseMap.Sample(sampler_NoiseMap,  input.positionWS.xz*0.1 + float2(_Time.x*2,0));
                half foamDistance = 1 - saturate(depthDistance / 2);
                half foamDynamic = smoothstep(_FoamWidth, _FoamWidth+0.2,frac(foamDistance + -_Time.y * 0.1 * _FoamSpeed)) * foamDistance *foamDistance;
                float foamStatic =  step(_FoamWidth, frac(foamDistance +  0.02525)) * foamDistance *
                    foamDistance;
                float foam = max(foamDynamic, foamStatic);
                // half foam = foamDynamic;
                finalColor += foam * LightLum;// * viewMask;
                // alpha = max(alpha,foam*0.5);


                #ifdef _DEBUG_FOAM
                return foam * LightLum * viewMask;
                #endif

                #endif

                //===================== CubeMap 反射 =======================================================================
                #ifdef _DEBUG_FRESNEL
                    return fresnel;
                #endif


                // return half4((inspecPart1)*6,1);

                // return fresnel;
                // cubeMap = cubeMap *(1-fresnel)*0.2;

                // return cubeMap;
                // finalColor += cubeMap*lerp(0.1,0.5,NL01)*LightLum;
                // reflection += cubeMap*0.5;


                #ifdef USE_SSR
                    half4 ssr =_SSRIntensity* WaterSSR(data.positionWS, lerp(float3(0,1,0),normalMap,_SSRNormalDistortion));
                    // return ssr;
                    finalColor = lerp( finalColor,ssr, saturate( fresnel));// + fresnel*0.1 ;

                #ifdef _DEBUG_SSR
                    return ssr;
                #endif

                #endif


                //===================== Cloud 云=======================================================================
                #ifdef USE_CLOUD
                half2 cloudMapUV = data.positionWS.xz*_CloudMap_ST.xy*0.01 + _WindDirection.xy* _CloudMoveSpeed*_Time.y;
                half cloudMap = SAMPLE_TEXTURE2D(_CloudMap,sampler_CloudMap,cloudMapUV).r;
                half cloud = cloudMap * _CloudIntensity * fresnel;
                finalColor +=cloud;

                #ifdef _DEBUG_CLOUD
                return cloud;
                #endif

                #endif

                //===================== CheapSSS =======================================================================
                #ifdef USE_CHEAPSSS
                half4 waterSSS = CheapSSS(N, L, V, _SSSDistance, _SSSExp, _SSSIntensity) * _SSSColor;
                finalColor += waterSSS;

                #ifdef _DEBUG_CHEAPSSS
                return waterSSS;
                #endif

                #endif

                #ifdef USE_SHADOW
                    // float shadow = lerp(_ShadowIntensity,1, light.shadowAttenuation);
                    // return shadow;
                    finalColor *= shadow;
                #endif

                #ifdef USE_CUBEMAP
                half mip = 0;//PerceptualRoughnessToMipmapLevel(1-_Smoothness); //unity 最大值7层mipmap
                half3 reflectVector = R;
                half4 encodedIrradiance = half4(SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectVector, mip));
                real3 inspecPart1 = DecodeHDREnvironment(encodedIrradiance, unity_SpecCube0_HDR);
                // finalColor.xyz += inspecPart1 * fresnel *2;
                // return encodedIrradiance;
                finalColor.xyz = lerp(finalColor.xyz,inspecPart1,saturate(fresnel*_CubeMapIntensity));
                // return encodedIrradiance.xyzz;
                #endif

                // finalColor.xyz += inspecPart1 * fresnel *_CubeMapIntensity*10;;
                // return half4(inspecPart1.xyz,1);
                finalColor.a = alpha;

                half fogFactor = InitializeInputDataFog(float4(data.positionWS, 1.0), 1);
                finalColor.rgb = MixFog(finalColor.rgb, fogFactor);
                return finalColor;
            }
            ENDHLSL
        }

        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }

            ZWrite On
            Cull[_Cull]
            // The HLSL code block. Unity SRP uses the HLSL language.
            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/EntityLighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ImageBasedLighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RealtimeLights.hlsl"
            // #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/GlobalIllumination.hlsl"

            sampler2D _BaseMap;
            sampler2D _BumpMap;
            sampler2D _MetallicMap;
            sampler2D _RoughnessMap;

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
                half _Roughness;
                half _Metallic;
            CBUFFER_END

            //Physically based Shading

            // This line defines the name of the vertex shader.
            #pragma vertex vert
            // This line defines the name of the fragment shader.
            #pragma fragment frag

            // The Core.hlsl file contains definitions of frequently used HLSL
            // macros and functions, and also contains #include references to other
            // HLSL files (for example, Common.hlsl, SpaceTransforms.hlsl, etc.).
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // The structure definition defines which variables it contains.
            // This example uses the Attributes structure as an input structure in
            // the vertex shader.
            struct Attributes
            {
                // The positionOS variable contains the vertex positions in object
                // space.
                float4 positionOS : POSITION;
                half3 normalOS : NORMAL;
                half2 uv : TEXCOORD0;
                half3 tangentOS : TANGENT;
                // float3 tangent : TANGENT;
            };

            struct Varyings
            {
                // The positions in this struct must have the SV_POSITION semantic.
                float4 positionHCS : SV_POSITION;
                half3 normalWS : TEXCOORD0;
                half3 positionWS : TEXCOORD1;
                half2 uv : TEXCOORD2;
                half3 tangentWS : TEXCOORD3;
            };


            // The vertex shader definition with properties defined in the Varyings
            // structure. The type of the vert function must match the type (struct)
            // that it returns.
            Varyings vert(Attributes IN)
            {
                // Declaring the output object (OUT) with the Varyings struct.
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);

                float3 positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.positionWS = positionWS;
                OUT.tangentWS = TransformObjectToWorldDir(IN.tangentOS);
                OUT.uv = IN.uv;
                return OUT;
            }

            // The fragment shader definition.
            half4 frag(Varyings data) : SV_Target
            {
                half3 N = SafeNormalize(data.normalWS);
                half3 T = SafeNormalize(data.tangentWS);
                half3 B = cross(N, T);
                half3x3 TBN = float3x3(T, B, N);
                half3 n = SafeNormalize(UnpackNormal(tex2D(_BumpMap, data.uv)));
                n = mul(n, TBN);
                return half4(n.xyz, 0);;
            }
            ENDHLSL
        }


    }
    CustomEditor "LWGUI.LWGUI"
}