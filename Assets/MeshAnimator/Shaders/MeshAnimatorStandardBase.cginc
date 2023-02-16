#include "UnityStandardCore.cginc"
#include "MeshAnimator.cginc"

struct MAVertexInput
{
	float4 vertex   : POSITION;
	float3 normal   : NORMAL;
	float2 uv0      : TEXCOORD0;
	float2 uv1      : TEXCOORD1;
#if defined(DYNAMICLIGHTMAP_ON) || defined(UNITY_PASS_META)
	float2 uv2      : TEXCOORD2;
#endif
#if defined(UNITY_STANDARD_USE_SHADOW_UVS) && defined(_PARALLAXMAP)
	half4 tangent   : TANGENT;
#endif
	uint vertexId : SV_VertexID;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

// convert MA input to default input
VertexInput MAConvertInput(MAVertexInput v) {
	VertexInput vertexInput = (VertexInput)0;
	vertexInput.uv0 = v.uv0;
	vertexInput.uv1 = v.uv1;
				
	#if defined(DYNAMICLIGHTMAP_ON) || defined(UNITY_PASS_META)
		vertexInput.uv2 = v.uv2;
	#endif

	#if defined(UNITY_STANDARD_USE_SHADOW_UVS) && defined(_PARALLAXMAP)
		vertexInput.tangent = v.tangent;
	#endif
	v.vertex = ApplyMeshAnimation(v.vertex, v.vertexId);
	v.normal = GetAnimatedMeshNormal(v.normal, v.vertexId); 
	vertexInput.vertex = v.vertex;
	vertexInput.normal = v.normal;
	return vertexInput;
}