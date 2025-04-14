using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class UI3DObj : MonoBehaviour
{
    [Tooltip("局部的渲染队列偏移值")]
    public int localRenderQueue = 0;

    public bool EnablePerspective = false;

    public float FOV = 0;
    public Vector2 DefaultWH = new Vector2(16,9);

    public bool SupportBatch = false;

    private UI3DPanel mPanel;

    private bool mStarted;

    private GameObject mGo;

    private Transform mTrans;

    public Transform cachedTransform { get { if (mTrans == null) mTrans = transform; return mTrans; } }

    public GameObject cachedGameObject { get { if (mGo == null) mGo = gameObject; return mGo; } }

    private List<Material> mRendererMats = new List<Material>();

    private Matrix4x4 mProjmtx;

    void Awake()
    {
        DefaultWH = new Vector2(Screen.width, Screen.height);
        mStarted = false;
        mGo = gameObject;
        mTrans = transform;
    }

    protected void Start()
    {
        mStarted = true;
        CreatePanel();
        RefrushRQ();
        SetPerspective();
    }


    private void SetPerspective()
    {
        if (!EnablePerspective)
            return;
        float fov = FOV;
        if(Screen.width%4 ==0 && Screen.height%3 == 0)
        {
            fov = FOV + (FOV - (((float)Screen.width/(float)Screen.height)/(DefaultWH.x/DefaultWH.y))*(FOV)) ;
        }
        mProjmtx = Matrix4x4.Perspective(fov, 1f, 0.1f, 500);
        mProjmtx = GL.GetGPUProjectionMatrix(mProjmtx, false);
        Shader.SetGlobalMatrix("_PerspCamProj", mProjmtx);
    }

    public void RefrushRQ()
    {
        if (mPanel == null || mPanel.PRenderQueue < 0)
            return;
        int count = mRendererMats.Count;
        if (count == 0)
            return;
        for (int i = 0; i < count; i++)
        {
            mRendererMats[i].renderQueue = Mathf.Min(mPanel.MaxRenderQueue, mPanel.PRenderQueue + localRenderQueue + 1);
        }
    }

    public void CheckLayer()
    {
        if (mPanel != null && mPanel.gameObject.layer != gameObject.layer)
        {
            Debug.LogWarning("You can't place widgets on a layer different than the UIPanel that manages them.\n" +
                "If you want to move widgets to a different layer, parent them to a new panel instead.", this);
            gameObject.layer = mPanel.gameObject.layer;
        }
    }

    public UI3DPanel CreatePanel()
    {
        UIPanel panel = null;
        if (mStarted && mPanel == null && enabled && NGUITools.GetActive(gameObject))
        {
            panel = UIPanel.Find(cachedTransform, false, cachedGameObject.layer);

            if (panel != null)
            {
                mPanel = panel.GetComponent<UI3DPanel>();
                if (mPanel == null)
                {
                    mPanel = panel.gameObject.AddComponent<UI3DPanel>();
                    mPanel.Init();
                }
                mPanel.onRenderQueueChange += RefrushRQ;
                CheckLayer();
                Renderer[] rrs = GetComponentsInChildren<Renderer>(true);
                if (rrs != null)
                {
                    Renderer rr = null;
                    Material mat = null;
                    ParticleSystemRenderer pr = null;
                    for (int i = 0; i < rrs.Length; i++)
                    {
                        rr = rrs[i].GetComponent<Renderer>();
                        if (rr != null)
                        {
                            pr = rr as ParticleSystemRenderer;
                            if (pr != null)
                            {
                                pr.sortingOrder = 0;
                            }
                            mat = rr.material;
                            if (mat != null)
                            {
                                mRendererMats.Add(mat);
                            }
                        }
                    }
                }

                if (SupportBatch)
                {
                    if (mPanel.BatchMgr == null)
                    {
                        mPanel.BatchMgr = mPanel.gameObject.AddComponent<Clishow.CsBatchMgr>();
                    }
                    if (mPanel.BatchMgr.Register(this.gameObject))
                    {
                        mPanel.BatchMgr.Add(this.gameObject);
                    }
                }
            }
        }
        return mPanel;
    }

    void OnDestroy()
    {
        if (mPanel != null && mPanel.gameObject != null && (mPanel.BatchMgr != null && !mPanel.BatchMgr.IsDestroy))
        {
            if (SupportBatch && mPanel.BatchMgr != null)
            {
                mPanel.BatchMgr.Delete(this.gameObject);
            }
            if (mPanel.onRenderQueueChange != null)
                mPanel.onRenderQueueChange -= RefrushRQ;
        }
    }

    void OnDisable()
    {
        mStarted = false;
        if (mPanel != null && mPanel.gameObject != null && (mPanel.BatchMgr != null && !mPanel.BatchMgr.IsDestroy))
        {
            if (SupportBatch && mPanel.BatchMgr != null)
            {
                mPanel.BatchMgr.Delete(this.gameObject);
            }
            if (mPanel.onRenderQueueChange != null)
                mPanel.onRenderQueueChange -= RefrushRQ;
        }
        mPanel = null;
    }

    void OnEnable()
    {
        mStarted = true;
        CreatePanel();
        RefrushRQ();
    }
}
