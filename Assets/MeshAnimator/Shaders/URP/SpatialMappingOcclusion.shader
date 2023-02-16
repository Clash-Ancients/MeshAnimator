Shader "Mesh Animator/Universal Render Pipeline/VR/SpatialMapping/Occlusion"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry-1" }
        LOD 100

        ZWrite On
        ZTest LEqual
        Colormask 0
        Cull Off

        Pass
        {
            Name "Spatial Mapping Occlusion"

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_instancing

            #include "UnlitInput.hlsl"
            // BEGIN GENERATED MESH ANIMATOR CODE
            #include "../MeshAnimator.hlsl"
            // END GENERATED MESH ANIMATOR CODE

            struct Attributes
            {
                float4 positionOS       : POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                // BEGIN GENERATED MESH ANIMATOR CODE
                uint vertexId        : SV_VertexID;
                // END GENERATED MESH ANIMATOR CODE
            };

            struct Varyings
            {
                float4 vertex  : SV_POSITION;

                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                // BEGIN GENERATED MESH ANIMATOR CODE
                float3 animatedPosition;
                float3 animatedNormal;	
                ApplyMeshAnimationValues_float(
                    input.positionOS.xyz,
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
                
                input.positionOS.xyz = animatedPosition;
                
                // END GENERATED MESH ANIMATOR CODE

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                output.vertex = vertexInput.positionCS;

                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                return half4(0,0,0,0);
            }
            ENDHLSL
        }
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}