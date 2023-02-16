#include "MeshAnimatorStandardBase.cginc"
#include "UnityStandardCoreForward.cginc"

// base pass
#if UNITY_STANDARD_SIMPLE
VertexOutputBaseSimple MAVertBase (MAVertexInput v) {
	VertexOutputBaseSimple o;
	UNITY_INITIALIZE_OUTPUT(VertexOutputBaseSimple, o);
#else
VertexOutputForwardBase MAVertBase (MAVertexInput v) {
	VertexOutputForwardBase o;
	UNITY_INITIALIZE_OUTPUT(VertexOutputForwardBase, o);
#endif
	UNITY_SETUP_INSTANCE_ID(v);
	VertexInput vertexInput = MAConvertInput(v);
	UNITY_TRANSFER_INSTANCE_ID(v, o);
	UNITY_TRANSFER_INSTANCE_ID(v, vertexInput);
	return vertBase(vertexInput);
}

// add pass
#if UNITY_STANDARD_SIMPLE
VertexOutputForwardAddSimple MAVertAdd (MAVertexInput v) {
	VertexOutputForwardAddSimple o;
	UNITY_INITIALIZE_OUTPUT(VertexOutputForwardAddSimple, o);
#else
VertexOutputForwardAdd MAVertAdd (MAVertexInput v) {
	VertexOutputForwardAdd o;
	UNITY_INITIALIZE_OUTPUT(VertexOutputForwardAdd, o);
#endif
	UNITY_SETUP_INSTANCE_ID(v);	
	VertexInput vertexInput = MAConvertInput(v);
	UNITY_TRANSFER_INSTANCE_ID(v, vertexInput);
	return vertAdd(vertexInput);
}