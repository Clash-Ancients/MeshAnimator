#ifndef UNIVERSAL_SHADOW_CASTER_PASS_INCLUDED
#define UNIVERSAL_SHADOW_CASTER_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
// BEGIN GENERATED MESH ANIMATOR CODE
#include "../MeshAnimator.hlsl"
// END GENERATED MESH ANIMATOR CODE

// Shadow Casting Light geometric parameters. These variables are used when applying the shadow Normal Bias and are set by UnityEngine.Rendering.Universal.ShadowUtils.SetupShadowCasterConstantBuffer in com.unity.render-pipelines.universal/Runtime/ShadowUtils.cs
// For Directional lights, _LightDirection is used when applying shadow Normal Bias.
// For Spot lights and Point lights, _LightPosition is used to compute the actual light direction because it is different at each shadow caster geometry vertex.
float3 _LightDirection;
float3 _LightPosition;

struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float2 texcoord     : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    // BEGIN GENERATED MESH ANIMATOR CODE
    uint vertexId        : SV_VertexID;
    // END GENERATED MESH ANIMATOR CODE
};

struct Varyings
{
    float2 uv           : TEXCOORD0;
    float4 positionCS   : SV_POSITION;
};

float4 GetShadowPositionHClip(Attributes input)
{
    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
    float3 normalWS = TransformObjectToWorldNormal(input.normalOS);

#if _CASTING_PUNCTUAL_LIGHT_SHADOW
    float3 lightDirectionWS = normalize(_LightPosition - positionWS);
#else
    float3 lightDirectionWS = _LightDirection;
#endif

    float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

#if UNITY_REVERSED_Z
    positionCS.z = min(positionCS.z, UNITY_NEAR_CLIP_VALUE);
#else
    positionCS.z = max(positionCS.z, UNITY_NEAR_CLIP_VALUE);
#endif

    return positionCS;
}

Varyings ShadowPassVertex(Attributes input)
{
    Varyings output;
    UNITY_SETUP_INSTANCE_ID(input);

    // BEGIN GENERATED MESH ANIMATOR CODE
    float3 animatedPosition;
    float3 animatedNormal;	
    ApplyMeshAnimationValues_float(
        input.positionOS.xyz,
        input.normalOS.xyz,
        UNITY_ACCESS_INSTANCED_PROP(Props, _AnimTimeInfo), 
        _AnimTextures,
        UNITY_ACCESS_INSTANCED_PROP(Props, _AnimTextureIndex), 
        UNITY_ACCESS_INSTANCED_PROP(Props, _AnimInfo),
        UNITY_ACCESS_INSTANCED_PROP(Props, _AnimScalar), 
        UNITY_ACCESS_INSTANCED_PROP(Props, _CrossfadeAnimTextureIndex), 
        UNITY_ACCESS_INSTANCED_PROP(Props, _CrossfadeAnimInfo), 
        UNITY_ACCESS_INSTANCED_PROP(Props, _CrossfadeAnimScalar), 
        UNITY_ACCESS_INSTANCED_PROP(Props, _CrossfadeStartTime),  
        UNITY_ACCESS_INSTANCED_PROP(Props, _CrossfadeEndTime),  
        input.vertexId,
        sampler_AnimTextures,
        animatedPosition,
        animatedNormal);
    
    input.positionOS.xyz = animatedPosition;
    
    // END GENERATED MESH ANIMATOR CODE

    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
    output.positionCS = GetShadowPositionHClip(input);
    return output;
}

half4 ShadowPassFragment(Varyings input) : SV_TARGET
{
    Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap)).a, _BaseColor, _Cutoff);
    return 0;
}

#endif