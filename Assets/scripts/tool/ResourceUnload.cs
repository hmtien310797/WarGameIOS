using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class ResourceUnload: MonoBehaviour
{
	public enum State
	{
		Done,
		Progress,
	}
			
	#region MonoBehavior methods
	State state = State.Done;

	public static ResourceUnload instance;

	void Awake()
	{
		instance = this;
	}

	void OnDestroy()
	{
		instance = null;
	}
	
	public void ReleaseUnusedResource()
	{
		if (state == ResourceUnload.State.Progress)
			return;
		
		state = ResourceUnload.State.Progress;
		StartCoroutine(Release());
	}

	public bool IsDone()
	{
		return state == State.Done;
	}
	
	IEnumerator Release()
	{
		yield return new WaitForSeconds(0.1f);

        float t = Time.realtimeSinceStartup;
		AsyncOperation async = Resources.UnloadUnusedAssets() ;
		//yield return async;
		while (!async.isDone)
		{
			yield return null;

            if(Time.realtimeSinceStartup - t > 10f)
            {
                Debug.LogError("ResourceUnload Release time out,Resources.UnloadUnusedAssets takes more than 10s");
                break;
            }
		}
		
		state = ResourceUnload.State.Done;
	}
	#endregion
}
