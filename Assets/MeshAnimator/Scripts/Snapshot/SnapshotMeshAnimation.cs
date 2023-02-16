//----------------------------------------------
// Mesh Animator
// Flick Shot Games
// http://www.flickshotgames.com
//----------------------------------------------

using UnityEngine;
using System.Collections.Generic;

namespace FSG.MeshAnimator.Snapshot
{
    [System.Serializable]
    public class SnapshotMeshAnimation : MeshAnimationBase
    {
        public static readonly Dictionary<Mesh, Dictionary<SnapshotMeshAnimation, Mesh[]>> GeneratedFrames = new Dictionary<Mesh, Dictionary<SnapshotMeshAnimation, Mesh[]>>();

        public override MeshFrameDataBase[] Frames { get { return frameData; } }
        public override int TotalFrames { get { return totalFrames; } }

        [Header("Preload all animation frames")]
        public bool preGenerateFrames = false;
        public MeshNormalMode meshNormalMode = MeshNormalMode.Baked;
        [Header("Only valid for Recalculated mode")]
        public bool recalculateNormalsOnRotation = false;
        [HideInInspector]
        public DeltaCompressedFrameData compressedFrameData;

        private SnapshotMeshFrameData[] frameData
        {
            get
            {
                if (compressedFrameData == null)
                    return new SnapshotMeshFrameData[0];
                if (decompressedFrameData == null || decompressedFrameData.Length == 0 || decompressedFrameData[0].verts == null)
                    decompressedFrameData = compressedFrameData;
                return decompressedFrameData;
            }
        }
        private Mesh[] frames = new Mesh[0];
        private int totalFrames = 0;
        private bool[] generatedMeshes;
        private bool completelyGenerated = false;
        private SnapshotMeshFrameData[] decompressedFrameData;
        private Quaternion lastRotation;
        private Queue<System.Action> mainThreadActions;
        private Dictionary<Mesh, KeyValuePair<int[], Vector3[]>> meshInfoCache;

        private void Awake()
        {
            decompressedFrameData = null;
        }
        protected override void OnEnable()
        {
            base.OnEnable();
            totalFrames = frameData.Length * frameSkip;
            if (frameData.Length > 0)
                vertexCount = frameData[0].verts.Length;
            generatedMeshes = new bool[totalFrames];
        }
        public override void SetFrameData(int frame, MeshFrameDataBase frameData)
        {
            var snapshotData = new SnapshotMeshFrameData();
            snapshotData.exposedTransforms = frameData.exposedTransforms;
            snapshotData.rootMotionPosition = frameData.rootMotionPosition;
            snapshotData.rootMotionRotation = frameData.rootMotionRotation;
            var tempData = decompressedFrameData;
            if (tempData == null)
                tempData = new SnapshotMeshFrameData[frame + 1];
            if (tempData.Length <= frame)
                System.Array.Resize(ref tempData, frame + 1);
            tempData[frame] = snapshotData;
            decompressedFrameData = tempData;
        }
        public override void SetFrameData(MeshFrameDataBase[] frameData)
        {
            decompressedFrameData = new SnapshotMeshFrameData[frameData.Length];
        }
        public override void DisplayFrame(IMeshAnimator meshAnimator, int frame, int previousFrame)
        {
            DisplayFrame(meshAnimator.MeshFilter, frame, previousFrame);
        }
        public override void GenerateFrames(Mesh baseMesh)
        {
            Dictionary<SnapshotMeshAnimation, Mesh[]> frameDictionary = null;
            Mesh[] meshFrames;
            if (GeneratedFrames.TryGetValue(baseMesh, out frameDictionary) && frameDictionary.TryGetValue(this, out meshFrames))
            {
                frames = meshFrames;
                return;
            }

            int genCount = preGenerateFrames ? frameData.Length * frameSkip : 1;
            for (int i = 0; i < genCount; i++) // only generate the first frame of each anim, unless preGenerateAllFrames = true
            {
                GenerateFrame(baseMesh, i);
            }

            if (frameDictionary == null)
            {
                frameDictionary = new Dictionary<SnapshotMeshAnimation, Mesh[]>();
                GeneratedFrames.Add(baseMesh, frameDictionary);
            }
            frameDictionary.Add(this, frames);
        }
        public override void GenerateFrame(Mesh baseMesh, int frame)
        {
            if (mainThreadActions != null && mainThreadActions.Count > 0)
            {
                try
                {
                    var action = mainThreadActions.Dequeue();
                    if (action != null)
                        action();
                }
                catch (System.Exception e)
                {
                    Debug.LogError(e);
                }
            }
            // if all frames have been made
            if (completelyGenerated)
                return;

            // if it's already made
            if (frames.Length > frame)
            {
                if (frames[frame] != null)
                    return;
            }

            // if another object already made it
            Dictionary<SnapshotMeshAnimation, Mesh[]> frameDictionary;
            Mesh[] frameArray;
            if (GeneratedFrames.TryGetValue(baseMesh, out frameDictionary) && frameDictionary.TryGetValue(this, out frameArray))
            {
                bool frameGenerated = false;
                if (frameArray.Length > frame)
                {
                    Mesh frameMesh = frameArray[frame];
                    if (frameMesh != null)
                    {
                        frameGenerated = true;
                    }
                }
                if (!completelyGenerated)
                {
                    CheckFullGeneration(frame);
                }
                if (frameGenerated)
                    return;
            }

            GenerateFrameInternal(baseMesh, frame);
        }
        public Vector3[] GetFrame(int frame)
        {
            bool needsInterp = frame % frameSkip != 0;
            if (needsInterp) //interpolate the vertex positions based on the frameSkip
            {
                float framePerc = (float)frame / (float)(frameSkip * frameData.Length);
                int skipFrame = (int)(framePerc * frameData.Length);

                float prevFramePerc = (float)skipFrame / (float)frameData.Length;
                float nextFramePerc = Mathf.Clamp01((float)(skipFrame + 1) / (float)frameData.Length);

                if (skipFrame >= frameData.Length)
                    skipFrame = frameData.Length - 1;
                if (skipFrame <= 0)
                    skipFrame = 0;
                Vector3[] previousFrame = frameData[skipFrame].verts;
                Vector3[] nextFrame;
                if (skipFrame + 1 >= frameData.Length)
                    nextFrame = frameData[0].verts;
                else
                    nextFrame = frameData[skipFrame + 1].verts;

                float lerpVal = Mathf.Lerp(0, 1, (framePerc - prevFramePerc) / (nextFramePerc - prevFramePerc));
                Vector3[] lerpedValues = new Vector3[previousFrame.Length];
                for (int i = 0; i < lerpedValues.Length; i++)
                    lerpedValues[i] = Vector3.Slerp(previousFrame[i], nextFrame[i], lerpVal);
                return lerpedValues;
            }
            else
            {
                int f = frame / frameSkip;
                if (f >= 0 && f < frameData.Length)
                    return frameData[frame / frameSkip].verts;
                else
                    return frameData[0].verts;
            }
        }
        public override void Reset()
        {
            completelyGenerated = false;
            if (generatedMeshes != null)
            {
                for (int i = 0; i < generatedMeshes.Length; i++)
                {
                    generatedMeshes[i] = false;
                }
            }
            for (int i = 0; i < frames.Length; i++)
            {
                Mesh m = frames[i];
                if (m != null)
                    Destroy(m);
            }
            frames = new Mesh[0];
        }
#if UNITY_EDITOR
        public override void CreateBakedAssets(string path, List<List<Vector3>> meshFramePositions, List<List<Vector3>> frameNormals)
        {
            if (decompressedFrameData == null)
            {
                decompressedFrameData = new SnapshotMeshFrameData[meshFramePositions.Count];
            }
            else if (decompressedFrameData.Length != meshFramePositions.Count)
            {
                System.Array.Resize(ref decompressedFrameData, meshFramePositions.Count);
            }
            for (int i = 0; i < meshFramePositions.Count; i++)
            {
                if (decompressedFrameData[i] == null)
                    decompressedFrameData[i] = new SnapshotMeshFrameData();
                decompressedFrameData[i].SetVerts(meshFramePositions[i].ToArray());
                if (meshNormalMode == MeshNormalMode.Baked)
                {
                    decompressedFrameData[i].normals = frameNormals[i].ToArray();
                }
            }
            compressedFrameData = decompressedFrameData;
        }
        public override void CompleteBake(IMeshAnimation[] animations, params object[] parameters) { }
#endif

        private void DisplayFrame(MeshFilter meshFilter, int frame, int previousFrame)
        {
            if (frame != previousFrame)
            {
                meshFilter.mesh = frames[frame];
                if (recalculateNormalsOnRotation && meshNormalMode == MeshNormalMode.Recalculated)
                {
                    Quaternion rot = meshFilter.transform.rotation;
                    if (lastRotation != rot)
                    {
                        lastRotation = rot;
                        RecalculateNormals(frames[frame]);
                    }
                }
            }
        }
        private void CheckFullGeneration(int newFrame)
        {
            if (completelyGenerated)
                return;
            generatedMeshes[newFrame] = true;
            completelyGenerated = true;
            for (int i = 0; i < generatedMeshes.Length; i++)
            {
                if (!generatedMeshes[i])
                {
                    completelyGenerated = false;
                    break;
                }
            }
        }
        private Mesh GenerateFrameInternal(Mesh baseMesh, int frame)
        {
            if (frames.Length == 0)
                frames = new Mesh[frameData.Length * frameSkip];
            bool needsInterp = frame % frameSkip != 0;
            if (needsInterp) //interpolate the vertex positions based on the frameSkip
            {
                float framePerc = (float)frame / (float)(frameSkip * frameData.Length);
                int skipFrame = (int)(framePerc * frameData.Length);

                float prevFramePerc = (float)skipFrame / (float)frameData.Length;
                float nextFramePerc = Mathf.Clamp01((float)(skipFrame + 1) / (float)frameData.Length);

                // lerp vertices
                Vector3[] previousFrame = frameData[skipFrame].verts;
                Vector3[] nextFrame;
                if (skipFrame + 1 >= frameData.Length)
                    nextFrame = frameData[0].verts;
                else
                    nextFrame = frameData[skipFrame + 1].verts;

                float lerpVal = Mathf.Lerp(0, 1, (framePerc - prevFramePerc) / (nextFramePerc - prevFramePerc));
                Vector3[] lerpedValues = new Vector3[previousFrame.Length];
                for (int i = 0; i < lerpedValues.Length; i++)
                {
                    lerpedValues[i] = Vector3.Lerp(previousFrame[i], nextFrame[i], lerpVal);
                }

                // lerp normals
                Vector3[] lerpedNormals = null;
                if (meshNormalMode == MeshNormalMode.Baked)
                {
                    previousFrame = frameData[skipFrame].normals;
                    if (skipFrame + 1 >= frameData.Length)
                        nextFrame = frameData[0].normals;
                    else
                        nextFrame = frameData[skipFrame + 1].normals;

                    lerpVal = Mathf.Lerp(0, 1, (framePerc - prevFramePerc) / (nextFramePerc - prevFramePerc));
                    lerpedNormals = new Vector3[previousFrame.Length];
                    for (int i = 0; i < lerpedNormals.Length; i++)
                    {
                        lerpedNormals[i] = Vector3.Lerp(previousFrame[i], nextFrame[i], lerpVal);
                    }
                }

                // create the mesh
                Mesh newmesh = Instantiate(baseMesh);
                newmesh.vertices = lerpedValues;
                newmesh.RecalculateBounds();
                if (meshNormalMode == MeshNormalMode.Recalculated)
                    RecalculateNormals(newmesh);
                else if (meshNormalMode == MeshNormalMode.Baked)
                    newmesh.normals = lerpedNormals;
                frames[frame] = newmesh;
            }
            else
            {
                // create the mesh
                Mesh newmesh = Instantiate(baseMesh);
                newmesh.vertices = frameData[frame / frameSkip].verts;
                newmesh.RecalculateBounds();
                if (meshNormalMode == MeshNormalMode.Recalculated)
                    RecalculateNormals(newmesh);
                else if (meshNormalMode == MeshNormalMode.Baked)
                    newmesh.normals = frameData[frame / frameSkip].normals;
                frames[frame] = newmesh;
            }
            if (!completelyGenerated)
            {
                CheckFullGeneration(frame);
            }
            return frames[frame];
        }
        private void RecalculateNormals(Mesh mesh)
        {
            mesh.RecalculateNormals();
            mesh.RecalculateTangents();
        }
        private void RecalculateNormals(Mesh mesh, float angle, int[] triangles, Vector3[] vertices, bool instant = false)
        {
            if (triangles == null)
            {
                if (meshInfoCache == null)
                    meshInfoCache = new Dictionary<Mesh, KeyValuePair<int[], Vector3[]>>();
                if (meshInfoCache.ContainsKey(mesh))
                {
                    triangles = meshInfoCache[mesh].Key;
                    vertices = meshInfoCache[mesh].Value;
                }
                else
                {
                    triangles = mesh.GetTriangles(0);
                    vertices = mesh.vertices;
                    meshInfoCache.Add(mesh, new KeyValuePair<int[], Vector3[]>(triangles, vertices));
                }
            }
            var triNormals = AllocatedArray<Vector3>.Get(triangles.Length / 3);
            var normals = AllocatedArray<Vector3>.Get(vertices.Length);

            angle = angle * Mathf.Deg2Rad;

            var dictionary = PooledDictionary<Vector3, VertexEntry>.Get(vertices.Length, VectorComparer);

            //Goes through all the triangles and gathers up data to be used later
            for (var i = 0; i < triangles.Length; i += 3)
            {
                int i1 = triangles[i];
                int i2 = triangles[i + 1];
                int i3 = triangles[i + 2];

                //Calculate the normal of the triangle
                Vector3 p1 = vertices[i2] - vertices[i1];
                Vector3 p2 = vertices[i3] - vertices[i1];
                Vector3 normal = Vector3.Cross(p1, p2).normalized;
                int triIndex = i / 3;
                triNormals[triIndex] = normal;

                VertexEntry entry;
                //VertexKey key;

                //For each of the three points of the triangle
                //  > Add this triangle as part of the triangles they're connected to.

                if (!dictionary.TryGetValue(vertices[i1], out entry))
                {
                    entry = GenericObjectPool<VertexEntry>.Get();
                    entry.PopulateArrays();
                    dictionary.Add(vertices[i1], entry);
                }
                entry.Add(i1, triIndex);

                if (!dictionary.TryGetValue(vertices[i2], out entry))
                {
                    entry = GenericObjectPool<VertexEntry>.Get();
                    entry.PopulateArrays();
                    dictionary.Add(vertices[i2], entry);
                }
                entry.Add(i2, triIndex);

                if (!dictionary.TryGetValue(vertices[i3], out entry))
                {
                    entry = GenericObjectPool<VertexEntry>.Get();
                    entry.PopulateArrays();
                    dictionary.Add(vertices[i3], entry);
                }
                entry.Add(i3, triIndex);
            }

            foreach (var kvp in dictionary)
            {
                var value = kvp.Value;
                for (var i = 0; i < value.Count; ++i)
                {
                    var sum = new Vector3();
                    for (var j = 0; j < value.Count; ++j)
                    {
                        if (value.VertexIndex[i] == value.VertexIndex[j])
                        {
                            sum += triNormals[value.TriangleIndex[j]];
                        }
                        else
                        {
                            float dot = Vector3.Dot(
                                triNormals[value.TriangleIndex[i]],
                                triNormals[value.TriangleIndex[j]]);
                            dot = Mathf.Clamp(dot, -0.99999f, 0.99999f);
                            float acos = Mathf.Acos(dot);
                            if (acos <= angle)
                            {
                                sum += triNormals[value.TriangleIndex[j]];
                            }
                        }
                    }
                    normals[value.VertexIndex[i]] = sum.normalized;
                }
                value.Clear();
                GenericObjectPool<VertexEntry>.Return(value);
            }
            dictionary.ReturnToPool();
            if (instant == false)
            {
                if (mainThreadActions == null)
                    mainThreadActions = new Queue<System.Action>();
                mainThreadActions.Enqueue(() =>
                {
                    if (mesh) mesh.normals = normals;
                    AllocatedArray<Vector3>.Return(normals, false);
                });
            }
            else
            {
                mesh.normals = normals;
                AllocatedArray<Vector3>.Return(normals, false);
            }
        }

        public static IEqualityComparer<Vector3> VectorComparer = Comparers.Create<Vector3>((x, y) =>
            x.x == y.x && x.y == y.y && x.z == y.z, (x) => x.GetHashCode());

        private sealed class VertexEntry
        {
            private int _reserved = 8;

            public int[] TriangleIndex;
            public int[] VertexIndex;

            private int _count;

            public int Count { get { return _count; } }

            public VertexEntry()
            {
            }

            public void Add(int vertIndex, int triIndex)
            {
                //Auto-resize the arrays when needed
                if (_reserved == _count)
                {
                    _reserved *= 2;
                    System.Array.Resize(ref TriangleIndex, _reserved);
                    System.Array.Resize(ref VertexIndex, _reserved);
                }
                TriangleIndex[_count] = triIndex;
                VertexIndex[_count] = vertIndex;
                ++_count;
            }
            public void PopulateArrays()
            {
                TriangleIndex = AllocatedArray<int>.Get(_reserved);
                VertexIndex = AllocatedArray<int>.Get(_reserved);
            }
            public void Clear()
            {
                _count = 0;
                AllocatedArray<int>.Return(TriangleIndex, false);
                AllocatedArray<int>.Return(VertexIndex, false);
                TriangleIndex = null;
                VertexIndex = null;
            }
        }
    }
}