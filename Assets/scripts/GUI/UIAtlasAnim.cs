using UnityEngine;
using System.Collections.Generic;


public enum UIAtlasWrapMode
{
    UIAWM_Normal,
    UIAWM_LOOP,
}

[System.Serializable]
public class UIAtlasClip
{
    public string clipName;
    public int startFrame;
    public int endFrame;
    public uint fps;
    public UIAtlasWrapMode wrapMode = UIAtlasWrapMode.UIAWM_Normal;
    public string endPlayClipName;
    public delegate void SetSpriteFrameCallbcak(int frame);
    public delegate void ClipEndCallback();
    private SetSpriteFrameCallbcak onSetSpriteFrame;
    private ClipEndCallback onClipEnd;
    private float mCurTime = 0;
    private float mPreTime = 0;
    private int mCurFrame = 0;
    private float mFrameTime = 0;
    private bool mEnbale = false;

    public void Reset()
    {
        mCurTime = 0;
        mPreTime = 0;
        mCurFrame = startFrame;
        mFrameTime = 1.0f/(Mathf.Max(1.0f, (float)fps));
        mEnbale = true;
        if(onSetSpriteFrame != null)
        {
            onSetSpriteFrame(mCurFrame);
        }
    }

    public void Play(SetSpriteFrameCallbcak setframe,ClipEndCallback clipend)
    {
        onSetSpriteFrame = setframe;
        onClipEnd = clipend;
        Reset();
    }

    public void Stop()
    {
        onClipEnd = null;
        onSetSpriteFrame = null;
        mEnbale = false;
    }

    public void Update(float _dt)
    {
        if(!mEnbale)
            return;
        mCurTime += _dt;
        if(mCurTime - mPreTime >= mFrameTime)
        {
            mCurFrame ++;
            if(mCurFrame > endFrame)
            {
                if(wrapMode == UIAtlasWrapMode.UIAWM_LOOP)
                {
                    Reset();
                }
                else
                {
                    mEnbale = false;
                    if(onClipEnd != null)
                    {
                        onClipEnd();
                    }
                }
                return;
            }
            mPreTime = mCurTime;
            if(onSetSpriteFrame != null)
            {
                onSetSpriteFrame(mCurFrame);
            }
        }
    }
}

public class UIAtlasAnim : MonoBehaviour
{
    public string FrameSpritePrefix;

    public int TotalFrame;

    private string[]  FrameSpriteNames = null;

    public UIAtlasClip[] Clips = null;

    public string AutoPlayClipName;

    private List<string> mClipNames = null;

    private UIAtlasClip mCurClips = null;

    private UISprite mSprite;
    

    void Awake()
    {
        if(TotalFrame > 0)
        {
            FrameSpriteNames = new string[TotalFrame];
            for(int i =0,imax = TotalFrame;i<imax;i++)
            {
                if(TotalFrame < 10)
                    FrameSpriteNames[i] = string.Format("{0}{1:d}",FrameSpritePrefix,i);
                else
                if(TotalFrame < 100)
                    FrameSpriteNames[i] = string.Format("{0}{1:d2}",FrameSpritePrefix,i);
                else
                if(TotalFrame < 1000)
                {
                    FrameSpriteNames[i] = string.Format("{0}{1:d3}",FrameSpritePrefix,i);
                }
                
            }
        }
        if(Clips != null)
        {
            mClipNames = new List<string>(Clips.Length);
            for(int i =0,imax = Clips.Length;i<imax;i++)
            {
                mClipNames.Add( Clips[i].clipName);
            }
        }

        mSprite = GetComponent<UISprite>();
    }

    void Start()
    {
        if(!string.IsNullOrEmpty(AutoPlayClipName))
        {
            Play(AutoPlayClipName);
        }
    }

    void SetSpriteFrameCallbcak(int frame)
    {
        if(mSprite == null)
            return;
        if(TotalFrame == 0 || TotalFrame <= frame)
            return;
        mSprite.spriteName = FrameSpriteNames[frame];
    }

    void ClipEndCallback()
    {
        if(!string.IsNullOrEmpty(mCurClips.endPlayClipName))
        {
            Play(mCurClips.endPlayClipName);
        }
    }

    public void Play(string name)
    {
        if(mClipNames == null)
            return;
        int index = mClipNames.IndexOf(name);
        if(index < 0)
            return;
        _Play(index);
    }

    private void _Play(int index)
    {
        if(Clips == null || Clips.Length <= index)
            return;
        if(mCurClips != null)
            mCurClips.Stop();
        mCurClips = Clips[index];
        if(mCurClips !=null)
        {
            mCurClips.Play(SetSpriteFrameCallbcak,ClipEndCallback);
        }
    }

    void Update()
    {
        if(Input.GetKeyDown(KeyCode.A))
        {
            Play("idle");
        }
        if(Input.GetKeyDown(KeyCode.S))
        {
            Play("show");
        }
       
        if(mCurClips == null)
            return;
        mCurClips.Update(Time.deltaTime);
    }

    void OnDestroy()
    {
        if(mCurClips !=null)
        {
            mCurClips.Stop();
        }
        mCurClips = null;
    }
}
