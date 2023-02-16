#include "UnityStandardShadow.cginc"
#include "MeshAnimator.cginc"

struct MAShadowVertexInput
{
	float4 vertex   : POSITION;
	float3 normal   : NORMAL;
	float2 uv0      : TEXCOORD0;
#if defined(UNITY_STANDARD_USE_SHADOW_UVS) && defined(_PARALLAXMAP)
	half4 tangent   : TANGENT;
#endif
	uint vertexId : SV_VertexID;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

// convert MA input to default input
VertexInput MAShadowConvertInput(MAShadowVertexInput v) {
	VertexInput vertexInput = (VertexInput)0;
	vertexInput.uv0 = v.uv0;
#if defined(UNITY_STANDARD_USE_SHADOW_UVS) && defined(_PARALLAXMAP)
	vertexInput.tangent = v.tangent;
#endif
	v.vertex = ApplyMeshAnimation(v.vertex, v.vertexId);
	v.normal = GetAnimatedMeshNormal(v.normal, v.vertexId); 
	vertexInput.vertex = v.vertex;
	vertexInput.normal = v.normal;
	return vertexInput;
}

// shadow pass
void MAVertShadowCaster (MAShadowVertexInput v, out float4 opos : SV_POSITION
#ifdef UNITY_STANDARD_USE_SHADOW_OUTPUT_STRUCT
	, out VertexOutputShadowCaster o
#endif
#ifdef UNITY_STANDARD_USE_STEREO_SHADOW_OUTPUT_STRUCT
	, out VertexOutputStereoShadowCaster os
#endif
)
{
	VertexInput vertexInput = MAShadowConvertInput(v);
	UNITY_SETUP_INSTANCE_ID(v);
	UNITY_TRANSFER_INSTANCE_ID(v, vertexInput);
	vertShadowCaster(vertexInput, 
		opos
		#ifdef UNITY_STANDARD_USE_SHADOW_OUTPUT_STRUCT
			, o
		#endif
		#ifdef UNITY_STANDARD_USE_STEREO_SHADOW_OUTPUT_STRUCT
			, os
		#endif
		);
}