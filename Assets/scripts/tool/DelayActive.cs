using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DelayActive : MonoBehaviour
{
    [Serializable]
    public class DelayTarget
    {
        public Transform target;

        public float interval;

    }

    public List<DelayTarget> targetList = new List<DelayTarget>();

    public bool ignoreTimeScale;

    private Coroutine delayCoroutine = null;

    private bool mStarted = false;

    void OnInit()
    {
        if (targetList.Count > 0)
        {
            foreach (var item in targetList)
            {
                item.target.gameObject.SetActive(false);
            }

            if (delayCoroutine != null)
            {
                StopCoroutine(delayCoroutine);
            }

            delayCoroutine = StartCoroutine(DelayCoroutine());
        }
    }

    void Awake()
    {
        mStarted = false;
        delayCoroutine = null;
    }

    void Start()
    {
        mStarted = true;
        OnInit();
    }

    void OnEnable()
    {
        if (mStarted)
        {
            OnInit();
        }
    }

    IEnumerator DelayCoroutine()
    {
        foreach (var item in targetList)
        {
            if (item.interval > 0)
            {
                if (ignoreTimeScale)
                {
                    yield return new WaitForSecondsRealtime(item.interval);
                }
                else
                {
                    yield return new WaitForSeconds(item.interval);
                }
            }
            item.target.gameObject.SetActive(true);
        }
    }
}
