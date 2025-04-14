using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class UI3DPanel : MonoBehaviour
{
    public int AddRQueueRange = 0;
    [System.NonSerialized]
    public Clishow.CsBatchMgr BatchMgr = null;

    public delegate void OnRenderQueueChange();
    public OnRenderQueueChange onRenderQueueChange;
    private Dictionary<string,Material> mShareMats = new Dictionary<string, Material>();
    private bool mIsDestroy = false;
    public UIPanel mPanel;
    private int mPRenderQueue;
    public int PRenderQueue
    {
        get
        {
            return mPRenderQueue;
        }
    }

    public int MaxRenderQueue
    {
        get
        {
            return mPRenderQueue + mPanel.AddRQueueRange;
        }
    }


    void Awake()
    {
        mIsDestroy = false;
        if(mPanel == null)
        {
            Init();
        }
    }

    public void Init()
    {
        if(mPanel == null)
            mPanel = GetComponent<UIPanel>();
        mPanel.AddRQueueRange = AddRQueueRange;
        mPRenderQueue = -1;
    }

    void LateUpdate()
    {
        if(mPanel == null)
            return;
        int srq = mPanel.startingRenderQueue + mPanel.drawCalls.Count;
        if(mPRenderQueue != srq)
        {
            mPRenderQueue = srq;
            if(onRenderQueueChange != null)
            {
                onRenderQueueChange();
            }
        }
    }

    public Material CreateOrGetShareMat(Material source)
    {
        if(mIsDestroy)
            return source;
        if(source == null)
            return source;
        string name = source.name;
            name = name.Replace(" ","");
            int t = name.IndexOf('(');
            if(t > 0)
            {
                name = name.Substring(0,t);
            }
            name = name.Replace("_ui3d","");
        name += "_ui3d";
        if(mShareMats.ContainsKey(name))
            return mShareMats[name];
        Material mat = new Material(source);
        mat.name = name;
        mat.hideFlags = HideFlags.DontSave|HideFlags.HideInInspector;
        mat.CopyPropertiesFromMaterial(source);
        mShareMats.Add(name,mat);
        return mat;
    }

    public void ClearShareMat()
    {
        if(mIsDestroy)
            return;
        if(mShareMats.Count != 0)
        {
            foreach(Material mat in mShareMats.Values)
            {
                if(mat != null)
                {
                    Object.Destroy(mat);
                }
            }
            mShareMats.Clear();
        }
    }

    void OnDestroy()
    {
        ClearShareMat();
        mIsDestroy = true;
        onRenderQueueChange = null;
    }
}
