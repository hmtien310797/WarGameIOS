using UnityEngine;
using System.Collections;
using System.Runtime.InteropServices;

public class ManagedHeapLog : MonoBehaviour
{
    [DllImport("mono.dll")]
    public static extern long mono_gc_get_used_size();
    [DllImport("mono.dll")]
    public static extern long mono_gc_get_heap_size();

    
    private UILabel Label = null;

    System.Text.StringBuilder builder = new System.Text.StringBuilder();


    private class MemoryPeak
    {
        private float cur = -1;
        private float pre = -1;
        private float peak = -1;
        private float rang = -1;
        private int state = 0;

        public float Cur
        {
            get
            {
                return cur;
            }
        }

        public float Peak
        {
            get
            {
                return peak;
            }
        }

        public float Rang
        {
            get
            {
                return rang;
            }
        }

        public void Record(float size)
        {
            if(pre < 0)
            {
                pre = size;
                state = pre - cur > 0?1:-1; 
                peak = pre;
                rang = 0;
            }
            else
            {
                pre = cur;
                cur = size;
                if(cur != pre)
                {

                    int cs = pre - cur > 0?1:-1; 
                    if(cs != state)
                    {
                        state = cs;
                        rang = peak - pre;
                        peak = pre;
                    }
                }
            }
        }
    }

    private MemoryPeak mono_peak = new MemoryPeak();
    private MemoryPeak lua_peak = new MemoryPeak();

    public void UpdatePeak()
    {
        mono_peak.Record(mono_gc_get_used_size());
        lua_peak.Record(LuaClient.GetMainState().GetGCCount());
        builder.Clear();
        builder.AppendFormat("mono:{0:f2}M,{1:f2}M,{2:f2}M,\n Lua:{3:f2}M,{4:f2}M,{5:f2}M",
            mono_peak.Cur* 1.0f / 1024 / 1024,
            mono_peak.Peak* 1.0f / 1024 / 1024,
            mono_peak.Rang* 1.0f / 1024 / 1024,
            lua_peak.Cur/ 1024,
            lua_peak.Peak/ 1024,
            lua_peak.Rang/ 1024);
        if(Label != null)
        {
            Label.text = builder.ToString();
        }
        else
        {
            Debug.Log(builder.ToString());
        }
    }

    void printMemory()
    {

        long usedsize = mono_gc_get_used_size();
        long heapsize = mono_gc_get_heap_size();
        long reservedsize = heapsize - usedsize;
        builder.Clear();
        builder.AppendFormat("使用内存:{0}M,剩余内存{1}M,托管堆内存{2}M, Lua 使用内存:{3}M",usedsize* 1.0f / 1024 / 1024,reservedsize* 1.0f / 1024 / 1024,heapsize* 1.0f / 1024 / 1024, LuaClient.GetMainState().GetGCCount() / 1024);
        //print(builder.ToString());
        Debug.Log(builder.ToString());
        //Debug.Log("使用内存=" + usedsize * 1.0f / 1024 / 1024 + "M"+"剩余内存=" + reservedsize * 1.0f / 1024 / 1024 + "M"+"托管堆内存=" + heapsize * 1.0f / 1024 / 1024 + "M");
    }

    float mTime;

	// Use this for initialization
	void Start () {
	    mTime = 0;
        Label = GetComponent<UILabel>();
	}
	
	// Update is called once per frame
	void Update ()
    {
        UpdatePeak();
        mTime += Time.deltaTime;
        if (mTime >= 10)
        {
            LuaClient.GetMainState().LuaGC(LuaInterface.LuaGCOptions.LUA_GCCOLLECT,1);
            System.GC.Collect();
            Resources.UnloadUnusedAssets();
            mTime = 0;
        }
    }
}
