#ifndef UNIVERSAL_UNLIT_INPUT_INCLUDED
#define UNIVERSAL_UNLIT_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
// BEGIN GENERATED MESH ANIMATOR CODE
TEXTURE2D_ARRAY(_AnimTextures);
SAMPLER(sampler_AnimTextures);
UNITY_INSTANCING_BUFFER_START(Props)
	UNITY_DEFINE_INSTANCED_PROP(float, _AnimTextureIndex)
	UNITY_DEFINE_INSTANCED_PROP(float4, _AnimTimeInfo)
	UNITY_DEFINE_INSTANCED_PROP(float4, _AnimInfo)
	UNITY_DEFINE_INSTANCED_PROP(float4, _AnimScalar)
	UNITY_DEFINE_INSTANCED_PROP(float, _CrossfadeAnimTextureIndex)
	UNITY_DEFINE_INSTANCED_PROP(float4, _CrossfadeAnimInfo)
	UNITY_DEFINE_INSTANCED_PROP(float4, _CrossfadeAnimScalar)
	UNITY_DEFINE_INSTANCED_PROP(float, _CrossfadeStartTime)
	UNITY_DEFINE_INSTANCED_PROP(float, _CrossfadeEndTime)
UNITY_INSTANCING_BUFFER_END(Props)
// END GENERATED MESH ANIMATOR CODE

CBUFFER_START(UnityPerMaterial)
    float4 _BaseMap_ST;
    half4 _BaseColor;
    half _Cutoff;
    half _Surface;
CBUFFER_END

#ifdef UNITY_DOTS_INSTANCING_ENABLED
UNITY_DOTS_INSTANCING_START(MaterialPropertyMetadata)
    UNITY_DOTS_INSTANCED_PROP(float4, _BaseColor)
    UNITY_DOTS_INSTANCED_PROP(float , _Cutoff)
    UNITY_DOTS_INSTANCED_PROP(float , _Surface)
UNITY_DOTS_INSTANCING_END(MaterialPropertyMetadata)

#define _BaseColor          UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata_BaseColor)
#define _Cutoff             UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata_Cutoff)
#define _Surface            UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata_Surface)
#endif

#endif