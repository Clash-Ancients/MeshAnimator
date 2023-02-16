#include "MeshAnimatorStandardBase.cginc"
#include "UnityStandardMeta.cginc"

v2f_meta ma_vert_meta (MAVertexInput v)
{
    v2f_meta o;
	VertexInput vertexInput = MAConvertInput(v);
	return vert_meta(vertexInput);
}