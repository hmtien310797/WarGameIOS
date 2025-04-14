using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public static class ChangeSceneUtility
{
    public static IEnumerator ChangeNewScene(System.Action done_callback)
    {
        UnityEngine.SceneManagement.SceneManager.UnloadScene("load_middle");
        AsyncOperation operation = UnityEngine.SceneManagement.SceneManager.LoadSceneAsync("load_middle");
        while( !operation.isDone)
        {
            yield return -1;
        }
        Debug.LogWarning("QQQQQQQQQQQQQQQQQQQQQQQQQQQ            "+Time.frameCount);
        UnityEngine.RenderSettings.ambientMode = UnityEngine.Rendering.AmbientMode.Flat;
        if(done_callback != null)
        {
            done_callback();
        }
    }
}

public class ChangeSceneHeldObject : MonoBehaviour
{
    private static List<GameObject> mHeldObjs = new List<GameObject>();

    public static void ClearHeldObjects()
    {
        if(mHeldObjs.Count ==0 )
            return;
        for(int i =0,imax = mHeldObjs.Count;i<imax;i++)
        {
            if(mHeldObjs[i] != null)
                GameObject.DestroyObject( mHeldObjs[i]);
        }
        mHeldObjs.Clear();
    }

    public void Awake()
    {
#if SUPPORT_CHANGE_SCENE
        mHeldObjs.Add(this.gameObject);
        GameObject.DontDestroyOnLoad(this.gameObject);
#endif
    }

}
