using UnityEngine;
using FSG.MeshAnimator;

public class CrossFade : MonoBehaviour
{
    public MeshAnimatorBase meshAnimator;
    public bool crossFade = false;
    void Start()
    {
        meshAnimator.Play();
        meshAnimator.OnAnimationFinished += OnAnimationFinished;
    }
    void OnAnimationFinished(string anim)
    {
        string newAnim = string.Empty;
        switch (anim)
        {
            case "idle":
                newAnim = "run_forward";
                break;
            case "run_forward":
                newAnim = "run_backward";
                break;
            case "run_backward":
                newAnim = "run_left";
                break;
            case "run_left":
                newAnim = "run_right";
                break;
            case "run_right":
                newAnim = "idle";
                break;
        }
        if (crossFade)
            meshAnimator.Crossfade(newAnim);
        else
            meshAnimator.Play(newAnim);
    }
}