
// This shader fills the mesh shape with a color predefined in the code.
Shader "Custom/YourShaderName"
{
    // The properties block of the Unity shader. In this example this block is empty
    // because the output color is predefined in the fragment shader code.
    Properties
    {
        _BaseColor("Color", Color) = (1,1,1,1)
        _BaseMap("Base (RGB)", 2D) = "white" {}
        [Normal]_BumpMap("Normal (RGB)", 2D) = "bump" {}
        _MetallicMap("Metallic (R)", 2D) = "white" {}
        _RoughnessMap("Roughness (R)", 2D) = "white" {}
        _Metallic("Metallic", Range(0,1)) = 0.5
        _Roughness("Roughness", Range(0,1)) = 0.5
    }

    // The SubShader block containing the Shader code.
    SubShader
    {
        // SubShader Tags define when and under which conditions a SubShader block or
        // a pass is executed.
        Tags
        {
            "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"
        }
        Pass
        {
            // The HLSL code block. Unity SRP uses the HLSL language.
            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/EntityLighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ImageBasedLighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RealtimeLights.hlsl"
            // #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/GlobalIllumination.hlsl"
            float4 _BaseColor;
            sampler2D _BaseMap;
            sampler2D _BumpMap;
            sampler2D _MetallicMap;
            sampler2D _RoughnessMap;
            half _Roughness;
            half _Metallic;
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
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
                float3 tangentOS : TANGENT;
                // float3 tangent : TANGENT;
            };

            struct Varyings
            {
                // The positions in this struct must have the SV_POSITION semantic.
                float4 positionHCS : SV_POSITION;
                float3 normalWS : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float2 uv : TEXCOORD2;
                float3 tangentWS : TEXCOORD3;
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
                Light light = GetMainLight();
                float3 L = SafeNormalize(light.direction);
                float3 N = SafeNormalize(data.normalWS);
                float3 T = SafeNormalize(data.tangentWS);
                float3 B = cross(N, T);
                float3x3 TBN = float3x3(T, B, N);
                float3 n = SafeNormalize(UnpackNormal(tex2D(_BumpMap, data.uv)));
                n = mul(n, TBN);
                
                float3 V = SafeNormalize(_WorldSpaceCameraPos.xyz - data.positionWS);
                float3 H = SafeNormalize(L + V);
                float nv = saturate(dot(n, V));
                float nl = saturate(dot(n, L));
            
                float3 albedo = tex2D(_BaseMap, data.uv) * _BaseColor.rgb;


                half3 F0 = half3(0.04, 0.04, 0.04);
                _Metallic = tex2D(_MetallicMap, data.uv) * _Metallic;
                F0 = lerp(F0, albedo, _Metallic);
                half Roughness = tex2D(_RoughnessMap, data.uv) * _Roughness;
                 uint meshRenderingLayers = GetMeshRenderingLightLayer();
                //mainLightCalculate

                
                // #if defined(_ADDITIONAL_LIGHTS)
                uint pixelLightCount = GetAdditionalLightsCount();
               
                LIGHT_LOOP_BEGIN(pixelLightCount)
                    Light light = GetAdditionalLight(lightIndex, data.positionWS, half4(1,1,1,1));//unityFunction
                    if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
                    {
                        //addLightCalculate
                    }
                LIGHT_LOOP_END
                // #endif
                


                //间接光照,SampleSH 球谐函数/////////////////////////////////////////////////////////////////////////////
                // half3 F = fresnelSchlickRoughness(nv, F0, Roughness);
                // half3 kS = F;
                // half3 KD = 1 - kS;
                // KD *= 1 - _Metallic;
                // half3 diffuse = SampleSH(n) * albedo;
                // // return  inDiffuse.xyzz;
                // //间接高光，split sum approximation   一部分和diffuse一样加了对环境贴图卷积，不过这次用粗糙度区分了mipmap
                // half mip = PerceptualRoughnessToMipmapLevel(Roughness); //unity 最大值7层mipmap
                // half3 reflectVector = reflect(-V, n);
                // half4 encodedIrradiance = half4(
                //     SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectVector, mip));
                // real3 inspecPart1 = DecodeHDREnvironment(encodedIrradiance, unity_SpecCube0_HDR);
                // // float2 brdf = tex2D(_BRDF, float2(nv, Roughness)).rg;
                // float2 brdf = EnvBRDFApprox(Roughness, nv);
                // half3 inspectPart2 = (F * brdf.x + brdf.y);
                // half3 specular = inspecPart1 * inspectPart2;
                // float3 ambient = (diffuse * KD + specular);
                // float3 finalColor = ambient + directColor.xyz;
                return (albedo).xyzz;;
            }
            ENDHLSL
        }
    }
}