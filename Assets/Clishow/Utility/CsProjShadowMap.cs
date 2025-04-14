using UnityEngine;
using System.Collections;
using System.Collections.Generic;
namespace Clishow
{
    public class CsProjShadowMap:MonoBehaviour
    {
        [System.Serializable]
        public class ProjCfg
        {
            public bool SupportYIgnore = true;
            public LayerMask ShadowLayer;
            public LayerMask GroundLayer;
            public Vector3 LightDir;
            public float Hight = 40;
            public float ShadowStrength = 0.0218f;
            public Rect ShadowFixedRect;        }

        private Camera mMainCam;

        private Camera mProjCam;

        private Projector mProjector;

        private Matrix4x4 mMatVP;

        private Matrix4x4 mProjMatrix;

        private RenderTexture shadowTexture;

        private Material mPorjMat;

        private bool mIsActived = false;

        private float mHight;

        private bool mIsFixedShadowRect;

        private Vector3 mFixedCenterOffset;

        public bool Initialize(ProjCfg param,Color fogColor,float fogmax, bool fixedshadowRect = false)
        {
            mIsFixedShadowRect = fixedshadowRect;
            ProjCfg cfg = param;
            if (cfg == null)
                return false;
            mMainCam = Camera.main;
            if (mMainCam == null)
                return false;
            mHight = cfg.Hight;

            mProjCam = gameObject.AddComponent<Camera>();
            mProjCam.clearFlags = CameraClearFlags.SolidColor;
            mProjCam.backgroundColor = new Color(0, 0, 0, 0);
            mProjCam.cullingMask = cfg.ShadowLayer.value;
            mProjCam.orthographic = true;
            mProjCam.depth = -2;
            mProjCam.transform.localRotation = Quaternion.Euler(cfg.LightDir);
            //mProjCam.enabled = false;
            if (cfg.SupportYIgnore)
            {
                mProjCam.SetReplacementShader(Shader.Find("ShadowReplaceIgnore"), "RenderType");
            }
            else
            {
                mProjCam.SetReplacementShader(Shader.Find("ShadowReplace"), "RenderType");
            }


            int textureSize = (GameSetting.instance.option.mQualityLevel == 1 || GameSetting.instance.option.mQualityLevel == 0)?1024:2048;
            shadowTexture = new RenderTexture(textureSize, textureSize, 0, RenderTextureFormat.ARGB32);
            shadowTexture.name = "shadowTexture" + GetInstanceID();
            shadowTexture.isPowerOfTwo = true;
            shadowTexture.hideFlags = HideFlags.DontSave;
            mProjCam.targetTexture = shadowTexture;

            mProjector = gameObject.AddComponent<Projector>();
            mProjector.nearClipPlane = mMainCam.nearClipPlane;
            mProjector.farClipPlane = mMainCam.farClipPlane;
            mProjector.fieldOfView = mMainCam.fieldOfView;
            mProjector.ignoreLayers = cfg.GroundLayer.value;
            mProjector.orthographic = true;
            mMatVP = GL.GetGPUProjectionMatrix(mProjCam.projectionMatrix, true) * mProjCam.worldToCameraMatrix;

            mPorjMat = new Material(Shader.Find("ShadowMap"));
            mPorjMat.SetMatrix("ShadowMatrix", mMatVP);
            mPorjMat.SetFloat("_Strength", cfg.ShadowStrength);
            mPorjMat.SetFloat("_ShadowMapSize", textureSize);
            mPorjMat.SetColor("_FogColor",fogColor);
            mPorjMat.SetFloat("_FogLineMax",fogmax);
            mProjector.material = mPorjMat;
            mIsActived = true;
            if (!mIsFixedShadowRect)
                StartAdjust();
            else
                FixedAdjust(cfg.ShadowFixedRect);
            GameSetting.instance.NoticeSaveOptions += NoticeSaveOptions;
            CheckQualityLevel();
            return true;
        }

        private Vector3 mMaxPosition;
        private Vector3 mMinPosition;
        private Vector3 mCenter;
        private Bounds mBounds= new Bounds(Vector3.zero,Vector3.one);
        private int mCount;

        private void StartAdjust()
        {
            if (!mIsActived)
                return;
            mMaxPosition = -Vector3.one * 500000.0f;
            mMinPosition = Vector3.one * 500000.0f;
            mCenter = Vector3.zero;
            mCount = 0;
        }

        public void Adjust(Vector3 pos)
        {
            if (mIsFixedShadowRect)
                return;
            if (!mIsActived)
                return;
            mCenter += pos;
            mCount++;
            Vector3 tp = mProjCam.worldToCameraMatrix.MultiplyPoint3x4(pos);
            if (tp.x > mMaxPosition.x)
            {
                mMaxPosition.x = tp.x;
            }
            if (tp.y > mMaxPosition.y)
            {
                mMaxPosition.y = tp.y;
            }
            if (tp.z > mMaxPosition.z)
            {
                mMaxPosition.z = tp.z;
            }
            if (tp.x < mMinPosition.x)
            {
                mMinPosition.x = tp.x;
            }
            if (tp.y < mMinPosition.y)
            {
                mMinPosition.y = tp.y;
            }
            if (tp.z < mMinPosition.z)
            {
                mMinPosition.z = tp.z;
            }
        }


        private void FixedAdjust(Rect rect)
        {
            if (!mIsFixedShadowRect)
            {
                return;
            }
            mFixedCenterOffset = new Vector3(rect.center.x, 0, rect.center.y);
            Vector3 center = mMainCam.transform.position + mFixedCenterOffset;
            center -= mProjCam.transform.forward * mHight;
            mProjCam.transform.position = center;
            Vector3 off = rect.max - rect.min;
            Vector3 sizeOff = off;
            sizeOff.z = 0;
            float dis = sizeOff.magnitude;
            mProjCam.orthographicSize = Mathf.Max(17, dis);
            mProjector.orthographicSize = mProjCam.orthographicSize - 1;
            mProjCam.farClipPlane = off.z + 500;
            mMatVP = GL.GetGPUProjectionMatrix(mProjCam.projectionMatrix, true) * mProjCam.worldToCameraMatrix;
        }

        private void UpdateFixedAdjust()
        {
            Vector3 center = mMainCam.transform.position + mFixedCenterOffset;
            center -= mProjCam.transform.forward * mHight;
            mProjCam.transform.position = center;
            mMatVP = GL.GetGPUProjectionMatrix(mProjCam.projectionMatrix, true) * mProjCam.worldToCameraMatrix;
        }

        private bool EndAdjust()
        {
            if (mCount == 0)
                return false;
            if(mBounds.Contains(mMaxPosition) && mBounds.Contains(mMinPosition))
                return true;
            if((mBounds.max - mMaxPosition).sqrMagnitude < 4 && (mBounds.min - mMinPosition).sqrMagnitude < 4)
                return true;
            mBounds.max = mMaxPosition;
            mBounds.min = mMinPosition;
            mCenter /= mCount;
            mCenter -= mProjCam.transform.forward * mHight;
            mProjCam.transform.position = mCenter;
            
            Vector3 off = mMaxPosition - mMinPosition;
            Vector3 sizeOff = off;
            sizeOff.z = 0;
            float dis = sizeOff.magnitude;
            mProjCam.orthographicSize = Mathf.Max(17, dis);
            mProjector.orthographicSize = mProjCam.orthographicSize-1;
            mProjCam.farClipPlane = off.z + 100;
            mMatVP = GL.GetGPUProjectionMatrix(mProjCam.projectionMatrix, true) * mProjCam.worldToCameraMatrix;
            return true;
        }

        void LateUpdate()
        {
            if (!mIsActived)
                return;
            if (mIsFixedShadowRect)
            {
                UpdateFixedAdjust();
            }
            else
            {
                if (!EndAdjust())
                {
                    if (mProjector.enabled)
                        mProjector.enabled = false;
                    StartAdjust();
                    return;
                }
            }

            if (!mProjector.enabled)
                mProjector.enabled = true;
            mPorjMat.SetMatrix("ShadowMatrix", mMatVP);
            //mProjCam.Render();
            mPorjMat.SetTexture("_ShadowTex", shadowTexture);
            StartAdjust();
        }

        public World world;

        void OnPostRender()
        {
            if (world != null)
            {
                world.DrawSpriteNow();
            }
        }

        void OnDestroy()
        {         
            if(shadowTexture != null)   
                Destroy(shadowTexture);
            shadowTexture = null;      
            Resources.UnloadUnusedAssets();     
            GameSetting.instance.NoticeSaveOptions -= NoticeSaveOptions;
        }

        void NoticeSaveOptions()
        {
            CheckQualityLevel();
        }

        bool CheckQualityLevel()
        {
            bool enable = GameSetting.instance.option.mQualityLevel >= 1;
            if(enable != this.gameObject.activeSelf)
                this.gameObject.SetActive(enable);
            return enable;
        }
    }
}


