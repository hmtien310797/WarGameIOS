using UnityEngine;
using System.Collections;

public class CsAnimRandomPlayer : MonoBehaviour
{
    public Animation Anim;

    public string[] Anims;

    private string CurAnimName;
	// Use this for initialization
	void Start () {
        Anim.Play("idle01");	
	}

    private void PlayAnim()
    {
        if(string.IsNullOrEmpty(CurAnimName) || !Anim.IsPlaying(CurAnimName))
        {
            int index = Random.Range(0,Anims.Length);
            CurAnimName = Anims[index];
            Anim.CrossFadeQueued(CurAnimName,0.3f,QueueMode.PlayNow);
        }
    }
	
	// Update is called once per frame
	void Update () {
	    PlayAnim();
	}
}
