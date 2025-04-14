using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using Serclimax;

public class CountDown : MonoBehaviour
{
    public delegate void CountDownCallBack(string leftTime);
    private Dictionary<string, Counter> callbacks;
    private static CountDown instance;
    private float timer = 0;
    private List<string> needremove;
    private List<Counter> _counter;

    class Counter
    {
        public int lastTargetTime = 0;
        public int targetTime;
        public int leftTime;
        public CountDownCallBack callbcak;
    }

    public static CountDown Instance
    {
        get { return instance; }
    }

    void Awake()
    {
        callbacks = new Dictionary<string, Counter>();
        needremove = new List<string>();
        instance = this;
    }

    void Start()
    {

    }

    void Update()
    {
        while (needremove.Count > 0)
        {
            callbacks.Remove(needremove[needremove.Count - 1]);
            needremove.RemoveAt(needremove.Count - 1);
        }
        timer += GameTime.realDeltaTimeWithoutSpeedUp;
        if (timer >= 1)
        {
            timer -= 1;
            _counter = new List<Counter>(callbacks.Values);
            while (_counter.Count > 0)
            {
                Counter c = _counter[_counter.Count - 1];
                _counter.RemoveAt(_counter.Count - 1);
                int t = c.leftTime = c.targetTime - (int)GameTime.GetSecTime();
                if (t < 0)
                {
                    c.leftTime = 0;
                }
                if (c.callbcak != null)
                {
                    c.callbcak(GameTime.SecondToString3(c.leftTime));
                }
            }
            //foreach (var item in callbacks)
            //{
            //    //if (item.Value.lastTargetTime != item.Value.targetTime)
            //    //{
            //        int t = item.Value.leftTime = item.Value.targetTime - (int)GameTime.GetSecTime();
            //        if (t < 0)
            //        {
            //            item.Value.leftTime = 0;
            //        }
            //    if (item.Value.callbcak != null)
            //        {
            //            item.Value.callbcak(GameTime.SecondToString3(item.Value.leftTime));
            //        }
            //    //}
            //}
        }
    }

    public void Add(string id, int targetTimeStamp, CountDownCallBack callback)
    {
        if (callbacks.ContainsKey(id))
        {
            callbacks[id].lastTargetTime = callbacks[id].targetTime;
            callbacks[id].targetTime = targetTimeStamp;
            if (callback != null)
            {
                callbacks[id].callbcak = callback;
            }
            if (needremove.Contains(id))
            {
                needremove.Remove(id);
            }
        }
        else
        {
            Counter counter = new Counter();
            counter.targetTime = targetTimeStamp;
            counter.callbcak = callback;
            callbacks.Add(id, counter);
        }
        if (callback != null)
        {
            callback(GameTime.SecondToString3(targetTimeStamp - (int)GameTime.GetSecTime()));
        }
    }

    public void Remove(string id)
    {
        if (callbacks.ContainsKey(id))
        {
            needremove.Add(id);
        }
    }

    public void RemoveCallBack(string id)
    {
        if(callbacks.ContainsKey(id))
        {
            callbacks[id].callbcak = null;
        }
    }

    public string GetLeftTime(string id)
    {
        return GameTime.SecondToString2(callbacks[id].leftTime);
    }

    public void RemoveAll()
    {
        callbacks.Clear();
    }
}
