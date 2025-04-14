using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SMCInfo : MonoBehaviour
{
    [System.NonSerialized]
    public int smc_id;
    [System.NonSerialized]
    public int index;
    [System.NonSerialized]
    public int indexPool;
    [System.NonSerialized]
    public int poolID;
    [System.NonSerialized]
    public int indexCombiner;
    public bool IsAnimationLoop = false;
    public GameObject AnimationBones;

    public int wPosX;
    public int wPosY;

    public bool IsMulit = false;
    public Vector3 CenterWPos;
    public int mX;
    public int mY;

    public SkinnedMeshRenderer smr;
    public Transform LowShadow;
    public Animation anim;
    public Animator animator;

    private Transform mTrf;
    private GameObject mObj;
    private WorldHUDMgr hud;
    private WorldMapAnimationStatus worldMapAnimationStatus;
    private bool isAnima = false;
    private AnimationRect animationRect = new AnimationRect();
    private Vector3 endPos = Vector3.zero;
    private float timer = 0;
    private System.Random rand = new System.Random();
    public bool isActive = false;
    public bool isValid = false;

    private static readonly Vector3 HidePos = new Vector3(0, -1000, 0);

    public Transform trf
    {
        get
        {
            if (mTrf == null)
                mTrf = this.transform;
            return mTrf;
        }
    }

    public GameObject obj
    {
        get
        {
            if (mObj == null)
                mObj = this.gameObject;
            return mObj;
        }
    }

    public WorldHUDMgr HUD
    {
        get
        {
            return hud;
        }

        set
        {
            hud = value;
        }
    }

    public void Clear()
    {
        smc_id = -1;
        index = -1;
        indexPool = -1;
        poolID = -1;
        indexCombiner = -1;
    }

    public void Active()
    {
        if (anim != null)
        {
            if (anim.gameObject.name.Contains("panjun"))
            {                
                if (anim["idle"] != null)
                    anim["idle"].normalizedTime = rand.Next(0, 10) / 10f;
            }            
            if (IsAnimationLoop)
            {
                isActive = true;
                animationRect.minX = transform.localPosition.x - (16 - 1);
                animationRect.minY = transform.localPosition.z - (16 - 1);
                animationRect.maxX = transform.localPosition.x + (16 - 1);
                animationRect.maxY = transform.localPosition.z + (16 - 1);
                animationRect.StartPosition = transform.localPosition;
                animationRect.StartRotation = AnimationBones.transform.localRotation.eulerAngles;
                anim.enabled = true;
                timer = anim.GetClip("idle").length;                
                anim["idle"].normalizedTime = 0;
                anim["idle"].wrapMode = WrapMode.Once;
                anim.Play("idle");
                worldMapAnimationStatus = WorldMapAnimationStatus.Idle;
            }
            else {
                anim.enabled = true;
                anim.Play();
            }
        }       
        if (animator != null) {
            animator.enabled = true;
            animator.Play(0);
        }

        hud.Show();
        
    }

    public void Reset()
    {
        isValid = false;
        if (IsAnimationLoop)
        {
            worldMapAnimationStatus = WorldMapAnimationStatus.Stop;
            iTween.Stop(gameObject);
            iTween.Stop(AnimationBones);                      
            isActive = false;
            isAnima = false;            
            AnimationBones.transform.localRotation = Quaternion.Euler(animationRect.StartRotation);            
        }

        trf.position = HidePos;
        
        if (anim != null)
        {
            anim.enabled = false;
            anim.Stop();
        }

        if (animator != null)
        {
            animator.enabled = false;
            //animator.Stop();
        }

        hud.Hide();
    }

    public void ClearRenderInfo()
    {
        index = -1;
        indexCombiner = -1;
        isValid = false;
    }

    public void ResetActive() {
        if (IsAnimationLoop)
        {
            transform.localPosition = animationRect.StartPosition;
            AnimationBones.transform.localRotation = Quaternion.Euler(animationRect.StartRotation);
            anim.enabled = true;
            timer = anim.GetClip("idle").length;
            anim["idle"].wrapMode = WrapMode.Once;
            anim.Play("idle");
            worldMapAnimationStatus = WorldMapAnimationStatus.Idle;
        }
    }


    private void Update()
    {
        if (!IsAnimationLoop)
            return;
        switch (worldMapAnimationStatus) {
            case WorldMapAnimationStatus.Idle:
                if (timer > 0) {
                    if (!isAnima)
                    {
                        isAnima = true;
                        endPos.x = rand.Next(1, 100) * 0.01f * (animationRect.maxX - animationRect.minX) + animationRect.minX;
                        endPos.z = rand.Next(1, 100) * 0.01f * (animationRect.maxY - animationRect.minY) + animationRect.minY;
                        Hashtable args = new Hashtable();
                        Vector2 v2 = (new Vector2(transform.localPosition.x, transform.localPosition.z) - new Vector2(endPos.x, endPos.z)).normalized;
                        float angle = Mathf.Atan2(v2.y, v2.x) * Mathf.Rad2Deg;
                        angle += 90 - animationRect.StartRotation.y;
                        if (angle < 0)
                            angle = 360 + angle;
                        angle = 360 - angle;
                        args.Add("rotation", new Vector3(animationRect.StartRotation.x, angle, animationRect.StartRotation.z));
                        args.Add("time", timer);
                        args.Add("easeType", iTween.EaseType.linear);
                        iTween.RotateTo(AnimationBones, args);
                    }
                    timer -= Time.deltaTime;
                    if (timer <= 0) {
                        timer = rand.Next(2, 5);
                        anim.CrossFade("walk", 0.2f);
                        //anim.Play("walk");
                        iTween.Stop(AnimationBones);
                        isAnima = false;
                        worldMapAnimationStatus = WorldMapAnimationStatus.Run;
                    }
                }
                break;
            case WorldMapAnimationStatus.Show:
                if (timer > 0)
                {
                    timer -= Time.deltaTime;
                    if (timer <= 0)
                    {
                        timer = anim.GetClip("idle").length;
                        anim["idle"].wrapMode = WrapMode.Once;
                        //anim["Idle"].time
                        anim.CrossFade("idle", 0.2f);
                        //anim.Play("Idle");
                        worldMapAnimationStatus = WorldMapAnimationStatus.Idle;
                    }
                }
                break;
            case WorldMapAnimationStatus.Run:
                if (timer > 0)
                {
                    if (!isAnima) {
                        isAnima = true;
                        Hashtable args = new Hashtable();
                        args.Add("position", endPos);
                        args.Add("time", timer);
                        args.Add("easeType", iTween.EaseType.linear);
                        iTween.MoveTo(gameObject, args);
                    }
                    timer -= Time.deltaTime;
                    if (timer <= 0)
                    {
                        timer = anim.GetClip("stand").length;
                        anim.CrossFade("stand", 0.2f);
                        //anim.Play("stand");
                        iTween.Stop(gameObject);
                        isAnima = false;
                        worldMapAnimationStatus = WorldMapAnimationStatus.Show;
                    }
                }
                break;
            case WorldMapAnimationStatus.Stop:
              
                break;
        }
    }
}
public enum WorldMapAnimationStatus {
    Idle,
    Show,
    Run,
    Stop
}

public class AnimationRect {
    public Vector3 StartPosition;
    public Vector3 StartRotation;
    public float minX;
    public float minY;
    public float maxX;
    public float maxY;
}