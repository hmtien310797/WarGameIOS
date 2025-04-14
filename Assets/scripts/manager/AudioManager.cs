using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;
using System.Xml;
using System.IO;
using Clishow;
using Serclimax;
//namespace Clishow
//{
    public class AudioManager : CsSingletonBehaviour<AudioManager>
    {
        
        protected AudioSource mMusicAudio;
        protected AudioSource mSfxAudio;

        protected AudioClip mNextBGM;
        protected bool mNextLoop;

        protected float mTimer;
        protected float mFadeTime;
        protected float mVol;
        protected float mVolAmbience;
        protected bool mBeginFadeOut;
        protected bool mBeginFadeIn;

        public static AudioManager instance;
        public bool enableLog = false;

        private AudioListener mDefaultListener;

        private AudioClip mLastSfx;
        private float mLastSfxTime;
        private bool mIsGamePause = false;    

        private int sfxNum = 1;
        private bool mMusicOff = true;
        public bool MusicSwith
        {
            get
            {
                return GameSetting.instance.option.mMusicSetting;
            }
        }
        
        private bool mSfxOff = true;
        public bool SfxSwith
        {
            get
            {
                return GameSetting.instance.option.mSoundSetting;
            }
        }
    private Dictionary<string, int> mActiveAudio = new Dictionary<string, int>();
        private Dictionary<string, AudioClip> mBattleAudio = new Dictionary<string, AudioClip>();
        private List<AudioSource> mBattleSource = new List<AudioSource>();
        private Dictionary<string, List<AudioSource>> mActiveSource = new Dictionary<string, List<AudioSource>>();
        public Serclimax.ScTableData<Serclimax.Unit.ScUnitSfxCountData> mUnitSfxCountData = null;
        public Serclimax.ScTableData<Serclimax.Unit.ScUnitSfxCountData> UnitSfxCountData
        {
            get
            {
                if (mUnitSfxCountData == null)
                {
                    mUnitSfxCountData = Main.Instance.TableMgr.GetTable<Serclimax.Unit.ScUnitSfxCountData>();
                }
                return mUnitSfxCountData;
            }
            set
            {
                mUnitSfxCountData = value;
            }
        }

        private Dictionary<string, float> mAudioVolData = null;
        public Dictionary<string ,  float> AudioVolData
        {
            get
            {
                if(mAudioVolData == null)
                {
                    mAudioVolData = new Dictionary<string, float>();
                    foreach (KeyValuePair<int, Serclimax.Unit.ScUnitSfxCountData> sfxCData in UnitSfxCountData.Data)
                    {
                        if(!mAudioVolData.ContainsKey(sfxCData.Value._UnitSfxFile))
                        {
                            mAudioVolData[sfxCData.Value._UnitSfxFile] = sfxCData.Value._UnitSfxVol;
                        }
                    }
                }
                return mAudioVolData;
            }
        }

        protected virtual void Awake()
        {
            GameObject obj = gameObject;
            if (instance == null)
            {
                instance = this;

                mDefaultListener = GameObject.FindObjectOfType<AudioListener>();
                if (mDefaultListener == null)
                {
                    mDefaultListener = obj.AddComponent<AudioListener>();
                }
            }
            mSfxAudio = obj.AddComponent<AudioSource>();
            mMusicAudio = obj.AddComponent<AudioSource>();
            mMusicAudio.playOnAwake = false;
            AudioListener.volume = 1f;
        }

        protected void OnDestroy()
        {
        
            if (instance == this)
                instance = null;
        }

        public void ClearData()
        {
            mAudioVolData.Clear();
            mActiveSource.Clear();
            mBattleSource.Clear();
            mBattleAudio.Clear();
            mActiveAudio.Clear();
        }

        public void Update()
        {
#if PROFILER
        Profiler.BeginSample("AudioManager_Update");
#endif
            if (mBeginFadeOut)
            {
                mTimer += GameTime.realDeltaTime;
                if (mTimer >= mFadeTime)
                {
                    mTimer = 0;
                    mBeginFadeOut = false;
                    mMusicAudio.volume = 0;
                    mMusicAudio.clip = mNextBGM;
                    mMusicAudio.loop = mNextLoop;
                    mNextBGM = null;
                    if (mMusicAudio.clip)
                    {
                        mMusicAudio.Play();
                        mBeginFadeIn = true;
                    }
                }
                else
                {
                    mMusicAudio.volume = Mathf.Lerp(mVol, 0, mTimer / mFadeTime);
                }
            }

            else if (mBeginFadeIn)
            {
                mTimer += GameTime.realDeltaTime;
                if (mTimer >= mFadeTime)
                {
                    mTimer = 0;
                    mBeginFadeIn = false;
                    mMusicAudio.volume = mVol;
                }
                else
                {
                    mMusicAudio.volume = Mathf.Lerp(0, mVol, mTimer / mFadeTime);
                }
            }

            //update audio source listner
            foreach (KeyValuePair<string, List<AudioSource>> clipASource in mActiveSource)
            {
                if (clipASource.Value == null || clipASource.Value.Count == 0)
                    continue;

                for (int i = 0; i < clipASource.Value.Count; ++i)
                {
                    AudioSource ads = clipASource.Value[i];
                    if (ads != null)
                    {
                        if (!ads.isPlaying)
                        {
                            UpdateAudioClip(clipASource.Key, ads);
                        }
                    }
                }

            }
#if PROFILER
        Profiler.EndSample();
#endif
        }


        public void PlaySfx(AudioClip _clip, float _vol = 1, bool _lowOthers = false)
        {
            if (_clip)
            {
                if (mLastSfx == _clip && GameTime.realTime - mLastSfxTime < 0.01f)
                {
                    return;
                }
                if(mSfxAudio.isPlaying)
                {
                    //return;
                }
                mSfxAudio.PlayOneShot(_clip, _vol);
                mLastSfxTime = GameTime.realTime;
                mLastSfx = _clip;
            }
        }

        public void MusicSwitch(bool on_off)
        {
            mMusicOff = on_off;
        }
        public void SfxSwitch(bool on_off)
        {
            mSfxOff = on_off;
        }
        public bool SfxIsPlaying()
        {
            return mSfxAudio.isPlaying;
        }

        public void PlayUISfx(string sfxName, float _vol = 1, bool _lowOthers = false)
        {
            if (!SfxSwith) return;
            AudioClip sfx = null;
            sfx = ResourceLibrary.instance.GetUISfxSound(sfxName);

            if (AudioVolData.ContainsKey(sfxName))
            {
                _vol = AudioVolData[sfxName];
            }

            if (sfx == null)
            {
                DebugUtils.LogError("Play UI Sfx Faild! "+sfxName);
                return;
            }
                
            AudioSource.PlayClipAtPoint(sfx, transform.position, _vol);
        }

        public void PlaySfx(string sfxName, float _vol = 1 ,bool _lowOthers = false)
        {
            if (!SfxSwith) return;
            
        AudioClip sfx = null;
            if (!mBattleAudio.ContainsKey(sfxName))
            {
                sfx = ResourceLibrary.instance.GetSfxSound(sfxName);
                mBattleAudio[sfxName] = sfx;
            }
            else
            {
                mBattleAudio.TryGetValue(sfxName, out sfx);
            }
            if (sfx == null)
            {
                
                return;
            }
                

            PlaySfx(sfx, _vol, _lowOthers);
        }
        public void PlayCommonSfx(string sfxName , float _vol = 1 , bool _lowOthers = false)
        {
            if (!SfxSwith)
                return;

            if (AudioVolData.ContainsKey(sfxName))
            {
                _vol = AudioVolData[sfxName];
            }

            AudioClip sfx = null;
            if (!mBattleAudio.ContainsKey(sfxName))
            {
                sfx = ResourceLibrary.instance.GetCommonSound(sfxName);
                mBattleAudio[sfxName] = sfx;
            }
            else
            {
                mBattleAudio.TryGetValue(sfxName, out sfx);
            }
            if (sfx == null)
                return;

            PlaySfx(sfx, _vol, _lowOthers);
        }
           

        public bool PlaySfx(AudioSource Adsource, string sfxName/*AudioSource Adsource, string sfxConfig*/ )
        {
            if (!SfxSwith)
                return false;

            float sfxVol = 1;
            if (mIsGamePause)
                return false;
            
            AudioClip _clip = GetSfx(sfxName);

            if (_clip)
            {
                if (AudioVolData.ContainsKey(sfxName))
                {
                    sfxVol = AudioVolData[sfxName];
                }

                Adsource.clip = _clip;
                Adsource.PlayOneShot(_clip, sfxVol);
                AddAudioSourceListner(_clip.name, Adsource);
                return true;
            }
            return false;
        }


        public void AddAudioSourceListner(string sfxname, AudioSource adsource)
        {
            mActiveSource[sfxname].Add(adsource);
            mActiveAudio[sfxname] += 1;
            //Debug.LogError("sfxName : " + sfxname + " count :" + mActiveAudio[sfxname]);
        }
        public int GetSfxActiceCount(string sfxName)
        {
            int count = sfxNum;
            foreach (KeyValuePair<int, Serclimax.Unit.ScUnitSfxCountData> scdata in UnitSfxCountData.Data)
            {
                if (scdata.Value._UnitSfxFile.Equals(sfxName))
                {
                    count = scdata.Value._UnitSfxActiveCount;
                }
            }
            return count;
        }
        public AudioClip GetSfx(string sfxName)
        {
            AudioClip sfxClip = null;

            if (!mBattleAudio.ContainsKey(sfxName))
            {
                sfxClip = ResourceLibrary.instance.GetSfxSound(sfxName);
                mBattleAudio[sfxName] = sfxClip;

                mActiveAudio[sfxName] = 0;
                mActiveSource[sfxName] = new List<AudioSource>();
            }

            if (mActiveAudio[sfxName] < GetSfxActiceCount(sfxName))
            {
                sfxClip = mBattleAudio[sfxName];
            }
            //Debug.LogError("sfxName : " + sfxName + " count :" + mActiveAudio[sfxName]);
            return sfxClip;
        }
        public void UpdateAudioClip(string clipName, AudioSource ads)
        {
            if (!mBattleAudio.ContainsKey(clipName))
                return;
            if (!mActiveAudio.ContainsKey(clipName))
                return;
            if (!mActiveSource.ContainsKey(clipName))
                return;

            //update active count
            mActiveAudio[clipName] -= 1;
            if (mActiveAudio[clipName] < 0)
                mActiveAudio[clipName] = 0;
            
            //update active source
            int remindex = mActiveSource[clipName].IndexOf(ads);
            if (remindex >= 0 && remindex < mActiveSource[clipName].Count)
                mActiveSource[clipName].RemoveAt(remindex);

            //Debug.LogError("sfxName : " + clipName + " count :" + mActiveAudio[clipName] + "source count :" + mActiveSource[clipName].Count);
        }
        public void AddBattleAudio(AudioSource audioS)
        {
            mBattleSource.Add(audioS);
        }
        void RecoverVol()
        {
            AudioListener.volume = 1;
        }

        public void PlayMusic(AudioClip _clip, float _fadeTime, bool _loop, float _vol = 1)
        {
            if (!MusicSwith)
                return;

            /*
            if (AudioVolData.ContainsKey(_clip.name))
            {
                _vol = AudioVolData[_clip.name];
            }
            */
            mVol = _vol;
        StopMusic();
            if (_clip)
            {
                if (mMusicAudio.clip == _clip && _loop && mMusicAudio.loop)
                {
                    mMusicAudio.volume = _vol;
                    return;
                }

                if (_fadeTime > 0)
                {
                    mTimer = 0;
                    mFadeTime = _fadeTime;

                    if (mMusicAudio.clip)
                    {
                        mNextBGM = _clip;
                        mNextLoop = _loop;
                        mBeginFadeOut = true;
                        mBeginFadeIn = false;
                    }
                    else
                    {
                        mBeginFadeOut = false;
                        mBeginFadeIn = true;
                        mMusicAudio.clip = _clip;
                        mMusicAudio.loop = _loop;
                        mMusicAudio.volume = 0;
                        mMusicAudio.Play();
                    }
                }
                else
                {
                    mMusicAudio.clip = _clip;
                    mMusicAudio.loop = _loop;
                    mMusicAudio.volume = _vol;
                    mMusicAudio.Play();
                }
            }
            else
            {
                StopMusic();
            }
        }
        public void PlayMusic(string musicName, float _fadeTime, bool _loop, float _vol = 1)
        {
            if (!MusicSwith)
                return;
            
            AudioClip music = null;
            if (!mBattleAudio.ContainsKey(musicName))
            {
                music = ResourceLibrary.instance.GetMusic(musicName);
                //mBattleAudio[musicName] = music;
            }
            else
            {
                mBattleAudio.TryGetValue(musicName, out music);
            }
            if (music == null)
                return;

            PlayMusic(music, _fadeTime, _loop);

        }

        public virtual void StopMusic()
        {
            mMusicAudio.Stop();
            mMusicAudio.clip = null;
            mBeginFadeOut = false;
            mBeginFadeIn = false;
            mBattleAudio.Clear();
        }
        public void PauseSfx()
        {
            mIsGamePause = true;
            foreach (KeyValuePair<string, List<AudioSource>> clipASource in mActiveSource)
            {
                for (int i = 0; i < clipASource.Value.Count; ++i)
                {
                    AudioSource ads = clipASource.Value[i];
                    if (ads != null)
                    {
                        ads.Pause();
                    }
                }
            }
        }
        public void ResumeSfx()
        {
            mIsGamePause = false;
            foreach (KeyValuePair<string, List<AudioSource>> clipASource in mActiveSource)
            {
                for (int i = 0; i < clipASource.Value.Count; ++i)
                {
                    AudioSource ads = clipASource.Value[i];
                    if (ads != null)
                    {
                        ads.Pause();
                    }
                }
            }
        }
        public void StopSfx()
        {
            foreach (KeyValuePair<string, List<AudioSource>> clipASource in mActiveSource)
            {
                for (int i = 0; i < clipASource.Value.Count; ++i)
                {
                    AudioSource ads = clipASource.Value[i];
                    if (ads != null)
                    {
                        ads.Stop();
                        ads.clip = null;
                    }
                }
            }
        }
        public void SetMusic(bool bPause)
        {
            if (bPause)
            {
                mMusicAudio.volume = mVol;
                mMusicAudio.Play();
            }
            else
            {
                mMusicAudio.Pause();

            }
        }

        public void EnableDefaultListener(bool _enble)
        {
            if (mDefaultListener)
                mDefaultListener.enabled = _enble;
        }


    }




//}
