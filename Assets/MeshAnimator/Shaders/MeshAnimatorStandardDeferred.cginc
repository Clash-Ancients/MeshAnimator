#include "MeshAnimatorStandardBase.cginc"

// deferred pass
VertexOutputDeferred MAVertDeferred (MAVertexInput v) {
	VertexOutputDeferred o;
	UNITY_INITIALIZE_OUTPUT(VertexOutputDeferred, o);
	VertexInput vertexInput = MAConvertInput(v);
	UNITY_SETUP_INSTANCE_ID(v);
	UNITY_TRANSFER_INSTANCE_ID(v, o);
	UNITY_TRANSFER_INSTANCE_ID(v, vertexInput);
	return vertDeferred(vertexInput);
}