using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using Serclimax;

public class AnimColltroller : MonoBehaviour
{

    public delegate void FinishCallback(Transform trans);
    public FinishCallback finishCallback;

    public void SetFinishCallback(FinishCallback callback) { finishCallback = callback; }
    private Animator mAnimator;
    private bool mFinished = false;


    void Awake()
    {
        mAnimator = transform.GetComponent<Animator>();
        if(mAnimator == null)
        {
            Debug.LogError("wrong in animController.cs");
        }
    }

    void Start()
    {
        mFinished = false;
    }

    void OnDestroy()
    {
        finishCallback = null;
    }
    void Update()
    {
        if (!mAnimator) return;

        AnimatorStateInfo info = mAnimator.GetCurrentAnimatorStateInfo(0);

        if (info.normalizedTime >= 1.0f && mFinished == false)
        {
            //DoSomething();
            // Debug.LogError("anim finish");
            if (finishCallback != null)
                finishCallback(transform);
            mFinished = true;
        }
    }
}
