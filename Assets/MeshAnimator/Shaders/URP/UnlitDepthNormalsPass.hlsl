#ifndef UNIVERSAL_UNLIT_DEPTH_NORMALS_PASS_INCLUDED
#define UNIVERSAL_UNLIT_DEPTH_NORMALS_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
// BEGIN GENERATED MESH ANIMATOR CODE
#include "../MeshAnimator.hlsl"
// END GENERATED MESH ANIMATOR CODE

struct Attributes
{
    float3 normal       : NORMAL;
    float4 positionOS   : POSITION;
    float4 tangentOS    : TANGENT;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    // BEGIN GENERATED MESH ANIMATOR CODE
    uint vertexId        : SV_VertexID;
    // END GENERATED MESH ANIMATOR CODE
};

struct Varyings
{
    float4 positionCS   : SV_POSITION;
    float3 normalWS     : TEXCOORD1;

    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

Varyings DepthNormalsVertex(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    // BEGIN GENERATED MESH ANIMATOR CODE
    float3 animatedPosition;
    float3 animatedNormal;	
    ApplyMeshAnimationValues_float(
        input.positionOS.xyz,
        input.normal.xyz,
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

    output.positionCS = TransformObjectToHClip(input.positionOS.xyz);

    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normal, input.tangentOS);
    output.normalWS = NormalizeNormalPerVertex(normalInput.normalWS);

    return output;
}

float4 DepthNormalsFragment(Varyings input) : SV_TARGET
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    // Output...
    #if defined(_GBUFFER_NORMALS_OCT)
        float3 normalWS = normalize(input.normalWS);
        float2 octNormalWS = PackNormalOctQuadEncode(normalWS);             // values between [-1, +1], must use fp32 on some platforms
        float2 remappedOctNormalWS = saturate(octNormalWS * 0.5 + 0.5);     // values between [ 0,  1]
        half3 packedNormalWS = half3(PackFloat2To888(remappedOctNormalWS)); // values between [ 0,  1]
        return half4(packedNormalWS, 0.0);
    #else
        return half4(NormalizeNormalPerPixel(input.normalWS), 0.0);
    #endif
}

#endif