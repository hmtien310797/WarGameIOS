using System;
using System.Collections.Generic;
using UnityEngine;

using Serclimax;

namespace Clishow
{
    public abstract class CsSingletonBehaviour<T> : MonoBehaviour where T : CsSingletonBehaviour<T>
    {
        public delegate void InitializeFinishHandle();

        protected static T m_Instance = null;

        protected bool mInitialized = false;

        protected static bool mValid = true;

        public static bool isValid
        {
            get
            {
                return mValid;
            }
        }

        public bool Initialized
        {
            get
            {
                return mInitialized;
            }
        }

        public static T Instance
        {
            get
            {
                if (m_Instance == null)
                {
                    m_Instance = GameObject.FindObjectOfType(typeof(T)) as T;

                    // Object not found, we create a temporary one
                    if (m_Instance == null)
                    {
                        DebugUtils.LogWarning("Singleton Behaviour No instance of " + typeof(T).ToString() + ", a temporary one is created.");
                        m_Instance = new GameObject("Singleton of " + typeof(T).ToString(), typeof(T)).GetComponent<T>();
                        // Problem during the creation, this should not happen
                        if (m_Instance == null)
                        {
                            DebugUtils.LogWarning("Singleton Behaviour Problem during the creation of " + typeof(T).ToString());
                        }

                    }

                    if (m_Instance != null && m_Instance.IsAutoInit())
                    {
                        m_Instance.Initialize();
                    }

                    if (m_Instance.IsGlobal())
                    {
                        GameObject.DontDestroyOnLoad(m_Instance.gameObject);
                    }
                }
                return m_Instance;
            }
        }
        
        public virtual bool IsGlobal()
        {
            return false;
        }

        public virtual bool IsAutoInit()
        {
            return false;
        }

        public virtual void Initialize(object param = null)
        {
            if (mInitialized)
                return;
            mValid = true;
            mInitialized = true;
        }


        public  virtual void OnDestroy()
        {
            mValid = false;
            m_Instance = null;
        }

        protected virtual void OnApplicationQuit()
        {
            mValid = false;
            m_Instance = null;
        }
    }
    
}
