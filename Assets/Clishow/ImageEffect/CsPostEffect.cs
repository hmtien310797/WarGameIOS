using UnityEngine;
using System.Collections;

namespace Clishow
{
    [System.Serializable]
    public class ColorEffectCfg
    {
        public string name;
        [Range(0, 2)]
        public float Color_Brightness = 1.05f;
        [Range(0.5f, 1.5f)]
        public float Color_Contrast = 1.03f;
        [Range(-6, 6)]
        public float Color_Saturate = 1.5f;
    }

    [ExecuteInEditMode]
    [RequireComponent(typeof(Camera))]
    public class CsPostEffect : MonoBehaviour
    {
        private bool mEnableBloomEffect = false;

        [Range(0f, .99f)]
        public float Bloom_Threshold = 0.377f;

        [Range(0f, 3f)]
        public float Bloom_Intensity = 0.52f;

        public Color Bloom_Tint = Color.white;

        private bool mEnableBlurEffect = false;

        public bool EnableBlurEffect
        {
            get
            {
                return mEnableBlurEffect;
            }
        }

        public bool Blur_Gaussian = true;
        public int Blur_DownSample = 1;
        public float Blur_Radius = 1;

        private bool mEnableColorEffect = true;

        public bool EnableColorEffect
        {
            get
            {
                return mEnableColorEffect;
            }
        }


        private bool mEnableDesEffect = false;
        public bool EnablDestroyEffect
        {
            get
            {
                return mEnableDesEffect;
            }
        }

        [Range(0, 2)]
        public float Color_Brightness = 1.05f;
        [Range(0.5f, 1.5f)]
        public float Color_Contrast = 1.03f;
        [Range(-6, 6)]
        public float Color_Saturate = 1.5f;
        [Range(0, 1)]
        public float Color_Gray = 0;

        public Vector3 SceneCenter = Vector3.zero;

        public Vector3 SceneSize = Vector3.one * 1000;

        public float CMaskFarClip = 1;

        private Camera mMainCam = null;

        private Material mMat;

        private const int _colorRenderPass = 0;

        private const int _blurRenderPass = 1;

        private const int _bloomSampleRenderPass = 4;

        private const int _bloomCompositeRenderPass = 5;

        private const int _maskRenderPass = 6;

        private const int _maskBlendRenderPass = 7;

        private const int _cityDestroyPass = 8;


        private bool mSupport = false;

        private RenderTexture mStaticHlurImage = null;

        private bool mEnableStaticHlur = false;

        private bool mEnableMaskEffect = true;

        private bool mEnabled = true;

        public static string PostMaskLayerName = "PostMask";

        private bool mMaskInited = false;

        //private UnityEngine.Texture mDistortionNoiseTEx;

        public void OpenBlurEffect(bool enable_static)
        {
            if (!mSupport || !mEnabled)
                return;
            if (mEnableBlurEffect)
                return;
            mEnableStaticHlur = enable_static;
            mEnableBlurEffect = true;
            if (!enabled)
                enabled = true;
        }

        public void CloseBlurEffect()
        {
            if (!mSupport || !mEnabled)
                return;
            if (!mEnableBlurEffect)
                return;
            mEnableBlurEffect = false;
            if (mStaticHlurImage != null)
            {
                RenderTexture.ReleaseTemporary(mStaticHlurImage);
                mStaticHlurImage = null;
            }
            if (!mEnableColorEffect && !mEnableBlurEffect && !mEnableBloomEffect)
            {
                this.enabled = false;
            }
        }

        public void OpenColorEffect()
        {
            if (!mSupport || !mEnabled)
                return;
            if (mEnableColorEffect)
                return;

            mEnableColorEffect = true;
            if (!enabled)
                enabled = true;
        }

        public void CloseColorEffect()
        {
            if (!mSupport || !mEnabled)
                return;
            mEnableColorEffect = false;
            if (!mEnableColorEffect && !mEnableBlurEffect && !mEnableBloomEffect)
            {
                this.enabled = false;
            }
        }

        public void EnableDestroyEffect()
        {
            if (!mSupport || !mEnabled)
                return;
            if (mEnableDesEffect)
                return;
            mEnableDesEffect = true;
            if (!enabled)
                enabled = true;
        }

        public void DisableDestroyEffect()
        {
            if (!mSupport || !mEnabled)
                return;
            mEnableDesEffect = false;
            if (!mEnableColorEffect && !mEnableBlurEffect && !mEnableBloomEffect && !mEnableDesEffect)
            {
                this.enabled = false;
            }
        }

        public void OpenBloomEffect()
        {
            if (!mSupport || !mEnabled)
                return;
            if (mEnableBloomEffect)
                return;

            mEnableBloomEffect = true;
            if (!enabled)
                enabled = true;
        }

        public void CloseBloomEffect()
        {
            if (!mSupport || !mEnabled)
                return;
            mEnableBloomEffect = false;
            if (!mEnableColorEffect && !mEnableBlurEffect && !mEnableBloomEffect)
            {
                this.enabled = false;
            }
        }

        private float mTotalTime;
        private float mTime;
        private bool mNeedUpdateGray = false;
        private float mTargetGrayScaleAmount = 0;
        public void TweenGary(bool enable, float time)
        {
            if (!mSupport || !mEnabled)
                return;
            if (!mEnableColorEffect)
            {
                return;
            }
            if (enable)
            {
                Color_Gray = 0;
                mTargetGrayScaleAmount = 1;
            }
            else
            {
                Color_Gray = 1;
                mTargetGrayScaleAmount = 0;
            }
            this.enabled = true;
            this.gameObject.SetActive(true);
            mTime = Time.realtimeSinceStartup;
            mTotalTime = time;
            mNeedUpdateGray = true;
        }

        private float easeInQuad(float start, float end, float value)
        {
            end -= start;
            return end * value * value + start;
        }

        void UpdateGray()
        {
            if (!mNeedUpdateGray)
                return;
            float t = Time.realtimeSinceStartup - mTime;
            if (t >= mTotalTime)
            {
                mNeedUpdateGray = false;
                Color_Gray = mTargetGrayScaleAmount;
            }
            else
            {
                Color_Gray = easeInQuad(Color_Gray, mTargetGrayScaleAmount, t / mTotalTime);
            }
        }

        private Camera mMaskCam;
        private RenderTexture mMaskRenderTex;
        private int mMaskCount = 0;

        public void AddMask()
        {
            if (!mEnableMaskEffect)
                return;
            mMaskCount++;
        }

        public void RemoveMask()
        {
            if (!mEnableMaskEffect)
                return;
            mMaskCount--;
            if (mMaskCount <= 0)
            {
                mMaskCount = 0;
            }
        }

        private void InitMaskCam()
        {
            if (!mEnableMaskEffect)
                return;
            //mDistortionNoiseTEx = Resources.Load<UnityEngine.Texture>("noise");
            mMainCam = this.GetComponent<Camera>();
            Transform mtrf = mMainCam.transform.Find("MaskCam");

            if (mtrf == null)
            {
                GameObject obj = new GameObject("MaskCam");
                obj.transform.parent = this.transform;
                obj.transform.localPosition = Vector3.zero;
                obj.transform.localRotation = Quaternion.identity;
                mMaskCam = obj.AddComponent<Camera>();
            }
            else
            {
                mMaskCam = mtrf.gameObject.GetComponent<Camera>();
                if (mMaskCam == null)
                {
                    mMaskCam = mtrf.gameObject.AddComponent<Camera>();
                }
            }
            if (mMaskCam != null)
                mMaskCam.SetReplacementShader(Shader.Find("MaskReplace"), "RenderType");

            mMaskRenderTex = new RenderTexture(Screen.width, Screen.height, 16, RenderTextureFormat.ARGB32);


            mMaskCam.clearFlags = CameraClearFlags.SolidColor;
            mMaskCam.backgroundColor = Color.black;
            mMaskCam.fieldOfView = mMainCam.fieldOfView;
            mMaskCam.nearClipPlane = mMainCam.nearClipPlane;
            mMaskCam.farClipPlane = mMainCam.farClipPlane;
            mMaskCam.targetTexture = mMaskRenderTex;
            int l = 1 << LayerMask.NameToLayer(PostMaskLayerName);
            mMaskCam.cullingMask = mMainCam.cullingMask | (l);
            mMainCam.cullingMask &= ~(l);
            mMaskCam.enabled = false;
            mMaskInited = true;
        }

        private void PostMaskEffect(RenderTexture src, RenderTexture dest, RenderTexture camtex)
        {
            float light = 1.0f;
            float cont = QualitySettings.activeColorSpace == ColorSpace.Linear ? 1.0f + (light - 0.65f) / 2.2f : light;
            mMat.SetVector("_ColorBoost", new Vector4(light, cont, Color_Saturate, 0));
            RenderTexture tmp = RenderTexture.GetTemporary(src.width, src.height, 0, src.format);
            RenderTexture tmp2 = RenderTexture.GetTemporary(src.width, src.height, 0, src.format);
            Graphics.Blit(camtex, tmp, mMat, _colorRenderPass);
            mMat.SetTexture("_MaskTex", mMaskRenderTex);
            Graphics.Blit(tmp, tmp2, mMat, _maskRenderPass);
            //mMat.SetTexture("_DistortionNoiseTEx", mDistortionNoiseTEx); ;
            mMat.SetTexture("_Mask_Blend_Tex", tmp2);
            Graphics.Blit(src, dest, mMat, _maskBlendRenderPass);
            RenderTexture.ReleaseTemporary(tmp);
            RenderTexture.ReleaseTemporary(tmp2);
        }

        private void Init()
        {
            if (SystemInfo.supportsImageEffects == false)
            {
                enabled = false;
                return;
            }
            Shader shader = Shader.Find("PostEffect");
            if (shader != null && shader.isSupported == false)
            {
                enabled = false;
                return;
            }

            if (GUIMgr.Instance != null)
                GUIMgr.Instance.PostEffect = this;
            mSupport = true;
            mMat = new Material(shader);

            GameSetting.instance.NoticeSaveOptions += NoticeSaveOptions;
            CheckQualityLevel();
            InitMaskCam();
            InitColorEffect();

        }

        private void PostColorEffect(RenderTexture src, RenderTexture dest)
        {
            float cont = QualitySettings.activeColorSpace == ColorSpace.Linear ? 1.0f + (Color_Contrast - 1.0f) / 2.2f : Color_Contrast;
            mMat.SetVector("_ColorBoost", new Vector4(Color_Brightness, cont, Color_Saturate, Color_Gray));
            Graphics.Blit(src, dest, mMat, _colorRenderPass);
        }

        private void PostBlurEffect_DownSample(RenderTexture src, RenderTexture dest, int downsample = 1)
        {
            int w = src.width >> downsample;
            int h = src.height >> downsample;
            RenderTexture tmp1 = RenderTexture.GetTemporary(w, h, 0, src.format);
            RenderTexture tmp2 = RenderTexture.GetTemporary(w, h, 0, src.format);

            Graphics.Blit(src, tmp1);
            //Horizontal blur
            mMat.SetVector("_BlurOffsets", new Vector4(1f, 0f, 0f, 0f) * Blur_Radius);
            Graphics.Blit(tmp1, tmp2, mMat, _blurRenderPass + (Blur_Gaussian ? 1 : 0));

            //Vertical blur
            mMat.SetVector("_BlurOffsets", new Vector4(0f, 1f, 0f, 0f) * Blur_Radius);
            Graphics.Blit(tmp2, dest, mMat, _blurRenderPass + (Blur_Gaussian ? 1 : 0));

            RenderTexture.ReleaseTemporary(tmp1);
            RenderTexture.ReleaseTemporary(tmp2);
        }

        private void PostBlurEffect_Easy(RenderTexture src, RenderTexture dest, int downsample = 1)
        {
            int w = src.width >> downsample;
            int h = src.height >> downsample;
            RenderTexture tmp1 = RenderTexture.GetTemporary(w, h, 0, src.format);
            RenderTexture tmp2 = RenderTexture.GetTemporary(w, h, 0, src.format);

            Graphics.Blit(src, tmp1);
            //Horizontal blur
            mMat.SetVector("_BlurOffsets", new Vector4(1f, 0f, 0f, 0f) * Blur_Radius);
            Graphics.Blit(tmp1, tmp2, mMat, 3);

            //Vertical blur
            mMat.SetVector("_BlurOffsets", new Vector4(0f, 1f, 0f, 0f) * Blur_Radius);
            Graphics.Blit(tmp2, dest, mMat, 3);

            RenderTexture.ReleaseTemporary(tmp1);
            RenderTexture.ReleaseTemporary(tmp2);
        }

        private void PostBlurEffect(RenderTexture src, RenderTexture dest)
        {
            RenderTexture tmp1 = RenderTexture.GetTemporary(src.width, src.height, 0, src.format);

            //Horizontal blur
            mMat.SetVector("_BlurOffsets", new Vector4(1f, 0f, 0f, 0f));
            Graphics.Blit(src, tmp1, mMat, _blurRenderPass + (Blur_Gaussian ? 1 : 0));

            //Vertical blur
            mMat.SetVector("_BlurOffsets", new Vector4(0f, 1f, 0f, 0f));
            Graphics.Blit(tmp1, dest, mMat, _blurRenderPass + (Blur_Gaussian ? 1 : 0));

            RenderTexture.ReleaseTemporary(tmp1);
        }

        private void PostBloomEffect(RenderTexture src, RenderTexture dest)
        {
            mMat.SetFloat("_BloomThreshold", Bloom_Threshold);
            mMat.SetFloat("_BloomIntensity", Bloom_Intensity);
            mMat.SetColor("_BloomTint", Bloom_Tint);
            RenderTexture tmp = RenderTexture.GetTemporary(src.width, src.height, 0, src.format);
            RenderTexture bloomTex = RenderTexture.GetTemporary(src.width, src.height, 0, src.format);
            Graphics.Blit(src, tmp, mMat, _bloomSampleRenderPass);
            PostBlurEffect_Easy(tmp, bloomTex, 4);
            mMat.SetTexture("_BloomTex", bloomTex);
            Graphics.Blit(src, dest, mMat, _bloomCompositeRenderPass);
            RenderTexture.ReleaseTemporary(tmp);
            RenderTexture.ReleaseTemporary(bloomTex);
        }

        void NoticeSaveOptions()
        {
            CheckQualityLevel();
        }

        bool CheckQualityLevel()
        {
            mEnabled = GameSetting.instance.option.mQualityLevel >= 1;
            mEnableMaskEffect = false;
            if (GameSetting.instance.option.mQualityLevel == 1)
            {
                CloseBloomEffect();
            }
            else if (GameSetting.instance.option.mQualityLevel == 2)
            {
                //OpenBloomEffect();
                mEnableMaskEffect = true;
            }
            mEnableBlurEffect = false;
            if (mEnabled != this.enabled)
            {
                this.enabled = mEnabled;
            }
            return mEnabled;
        }

        void OnDestroy()
        {
            GameSetting.instance.NoticeSaveOptions -= NoticeSaveOptions;
            if (mStaticHlurImage != null)
            {
                RenderTexture.ReleaseTemporary(mStaticHlurImage);
                mStaticHlurImage = null;
            }

        }

        void Awake()
        {
            Init();
        }

        void Update()
        {
            if (!mEnableColorEffect && !mEnableBlurEffect && !mEnableBloomEffect)
            {
                this.enabled = false;
                return;
            }
            UpdateGray();
            if (mEnableMaskEffect && mMaskCam != null)
            {
                if (mMaskCam.enabled != mEnableMaskEffect)
                {
                    if (mMaskCount > 0)
                    {
                        mMaskCam.enabled = mEnableMaskEffect;
                    }
                    else
                    {
                        mMaskCam.enabled = false;
                    }
                }
                //mMaskCam.Render();
            }
            if (mEnableMaskEffect && !mMaskInited && mMaskCam == null)
            {
                InitMaskCam();
            }
            if (Input.GetKeyDown(KeyCode.N))
            {
                SetColorEffect("neight");
            }
            else
            if (Input.GetKeyDown(KeyCode.M))
            {
                SetColorEffect("morning");
            }
            UpdateColorEffect();

        }

        void OnRenderImage(RenderTexture src, RenderTexture dest)
        {
            if (!mEnableColorEffect && !mEnableBlurEffect && !mEnableBloomEffect)
            {
                Graphics.Blit(src, dest);
                return;
            }

            if (!mEnableColorEffect && !mEnableBlurEffect && mEnableBloomEffect)
            {
                PostBloomEffect(src, dest);
                return;
            }

            if (mEnableColorEffect)
            {
                if (mEnableBlurEffect)
                {
                    if (mEnableStaticHlur)
                    {
                        if (mStaticHlurImage == null)
                        {
                            mStaticHlurImage = RenderTexture.GetTemporary(src.width, Screen.height, 0, src.format);
                            RenderTexture tmp = RenderTexture.GetTemporary(src.width, Screen.height, 0, src.format);
                            PostColorEffect(src, tmp);
                            if (Blur_DownSample <= 1)
                                PostBlurEffect(tmp, mStaticHlurImage);
                            else
                                PostBlurEffect_DownSample(tmp, mStaticHlurImage, Blur_DownSample);
                            RenderTexture.ReleaseTemporary(tmp);
                        }
                        else
                        {
                            Graphics.Blit(mStaticHlurImage, dest);
                        }
                    }
                    else
                    {
                        RenderTexture tmp = RenderTexture.GetTemporary(src.width, Screen.height, 0, src.format);
                        PostColorEffect(src, tmp);
                        if (Blur_DownSample <= 1)
                            PostBlurEffect(tmp, dest);
                        else
                            PostBlurEffect_DownSample(tmp, dest, Blur_DownSample);
                        RenderTexture.ReleaseTemporary(tmp);
                    }

                }
                else
                {

                    if (mEnableBloomEffect)
                    {
                        RenderTexture tmp = RenderTexture.GetTemporary(src.width, Screen.height, 0, src.format);
                        PostColorEffect(src, tmp);
                        PostBloomEffect(tmp, dest);
                        RenderTexture.ReleaseTemporary(tmp);
                    }
                    else
                    {
                        if (mMaskCount > 0 && mEnableMaskEffect)
                        {
                            RenderTexture tmp = RenderTexture.GetTemporary(src.width, Screen.height, 0, src.format);
                            PostColorEffect(src, tmp);
                            PostMaskEffect(tmp, dest, src);
                            RenderTexture.ReleaseTemporary(tmp);
                        }
                        else if (mEnableDesEffect)
                        {

                            RenderTexture tmp = RenderTexture.GetTemporary(src.width, Screen.height, 0, src.format);
                            PostColorEffect(src, tmp);
                            Graphics.Blit(tmp, dest, mMat, _cityDestroyPass);
                            RenderTexture.ReleaseTemporary(tmp);
                        }
                        else
                            PostColorEffect(src, dest);
                    }
                }
                return;
            }

            if (mEnableBlurEffect)
            {
                if (mEnableStaticHlur)
                {
                    if (mStaticHlurImage == null)
                    {
                        mStaticHlurImage = RenderTexture.GetTemporary(src.width, Screen.height, 0, src.format);
                        if (Blur_DownSample <= 1)
                            PostBlurEffect(src, mStaticHlurImage);
                        else
                            PostBlurEffect_DownSample(src, mStaticHlurImage, Blur_DownSample);
                    }
                    else
                    {
                        Graphics.Blit(mStaticHlurImage, dest);
                    }
                }
                else
                {
                    if (Blur_DownSample <= 1)
                        PostBlurEffect(src, dest);
                    else
                        PostBlurEffect_DownSample(src, dest, Blur_DownSample);
                }
            }
        }

        private string mCurColorEffect;
        private System.Collections.Generic.Dictionary<string, ColorEffectCfg> mColorEffectCfgs =
            new System.Collections.Generic.Dictionary<string, ColorEffectCfg>();
        private ColorEffectCfg mNewEffect;
        private ColorEffectCfg mCurEffect;
        private bool mNeedUpdateEffect = false;
        private float mColorEffectTime = 0;
        public float ColorEffectTime = 1;
        void InitColorEffect()
        {
            ColorEffectCfg morning = new ColorEffectCfg();
            morning.name = "morning";
            morning.Color_Brightness = 1;
            morning.Color_Contrast = 1;
            morning.Color_Saturate = 1;
            mColorEffectCfgs.Add(morning.name, morning);
            ColorEffectCfg neight = new ColorEffectCfg();
            neight.name = "neight";
            neight.Color_Brightness = 0.45f;
            neight.Color_Contrast = 0.886f;
            neight.Color_Saturate = 0.25f;
            mColorEffectCfgs.Add(neight.name, neight);
        }

        public void SetColorEffect(string name)
        {
            if (mCurEffect != null && mCurEffect.name == name)
                return;

            if (mColorEffectCfgs.ContainsKey(name))
            {
                if (mCurEffect == null)
                {
                    mCurEffect = mColorEffectCfgs[name];
                }
                else
                {
                    mNewEffect = mColorEffectCfgs[name];
                }
                mNeedUpdateEffect = true;
                mColorEffectTime = 0;
            }
        }
        private float easeInQuart(float start, float end, float value)
        {
            end -= start;
            return end * value * value * value * value + start;
        }
        void UpdateColorEffect()
        {
            if (!mNeedUpdateEffect)
                return;
            if (mCurEffect == null)
            {
                mNeedUpdateEffect = false;
                return;
            }
            if (mNewEffect == null && mCurEffect != null)
            {
                Color_Brightness = mCurEffect.Color_Brightness;
                Color_Contrast = mCurEffect.Color_Contrast;
                Color_Saturate = mCurEffect.Color_Saturate;
                mNeedUpdateEffect = false;
                return;
            }
            mColorEffectTime += Time.deltaTime;
            if (mColorEffectTime >= ColorEffectTime)
            {
                Color_Brightness = mNewEffect.Color_Brightness;
                Color_Contrast = mNewEffect.Color_Contrast;
                Color_Saturate = mNewEffect.Color_Saturate;
                mCurEffect = mNewEffect;
                mNewEffect = null;
                mNeedUpdateEffect = false;
                return;
            }
            float f = Mathf.Min(1, mColorEffectTime / ColorEffectTime);
            Color_Brightness = easeInQuart(mCurEffect.Color_Brightness, mNewEffect.Color_Brightness, f);
            Color_Contrast = easeInQuart(mCurEffect.Color_Contrast, mNewEffect.Color_Contrast, f);
            Color_Saturate = easeInQuart(mCurEffect.Color_Saturate, mNewEffect.Color_Saturate, f);
        }
    }
}

