using UnityEngine;
using FSG.MeshAnimator;

public class CrossFade : MonoBehaviour
{
    public MeshAnimatorBase meshAnimator;
    public bool crossFade = false;
    void Start()
    {
        meshAnimator.Play();
        meshAnimator.eventReciever = gameObject;
        //meshAnimator.OnAnimationFinished += OnAnimationFinished;
    }
    void OnAnimationFinished(string anim)
    {
        string newAnim = string.Empty;
        switch (anim)
        {
            case "KickAttack":
                newAnim = "Idle";
                break;
            
        }
        
        meshAnimator.Crossfade(newAnim);
    }

    public void EventAnimEnd(object anim)
    {
        string newAnim = string.Empty;
        string strAnim = (string)anim;
        switch (strAnim)
        {
            case "KickAttack":
                newAnim = "Idle";
                break;
            
        }
        
        meshAnimator.Crossfade(newAnim, 0.01f);
    }

    public void OnClickBtn(string _name)
    {
        switch (_name)
        {
            case "KickAttack":
            {
                meshAnimator.Crossfade(_name, 0.01f);
                break;
            }
            case "run":
            {
                meshAnimator.Crossfade(_name, 0.01f);
                break;
            }
        }
            
        
    }
}