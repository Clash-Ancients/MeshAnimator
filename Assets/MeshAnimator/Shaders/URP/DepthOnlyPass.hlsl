#ifndef UNIVERSAL_DEPTH_ONLY_PASS_INCLUDED
#define UNIVERSAL_DEPTH_ONLY_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
// BEGIN GENERATED MESH ANIMATOR CODE
#include "../MeshAnimator.hlsl"
// END GENERATED MESH ANIMATOR CODE

struct Attributes
{
    float4 position     : POSITION;
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
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

Varyings DepthOnlyVertex(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    // BEGIN GENERATED MESH ANIMATOR CODE
    float3 animatedPosition;
    float3 animatedNormal;	
    ApplyMeshAnimationValues_float(
        input.position.xyz,
        float3(0, 0, 0),
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
    
    input.position.xyz = animatedPosition;
    
    // END GENERATED MESH ANIMATOR CODE

    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
    output.positionCS = TransformObjectToHClip(input.position.xyz);
    return output;
}

half4 DepthOnlyFragment(Varyings input) : SV_TARGET
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap)).a, _BaseColor, _Cutoff);
    return 0;
}
#endif