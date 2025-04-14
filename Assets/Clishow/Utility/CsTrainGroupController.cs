using UnityEngine;
using System.Collections;

public class CsTrainGroupController : MonoBehaviour
{
    public Animation[] Anims;

    public float MaxDelay;
    public float MinDelay;

    private float Delay;

    private float mDelay;

	// Use this for initialization
	void Start () {
	    Delay = Random.Range(MinDelay,MaxDelay);
	}
	
	// Update is called once per frame
	void Update ()
    {
        bool play = Anims[Anims.Length - 1].isPlaying;
        if(play)
            return;
        if(mDelay >= Delay)
        {
           for(int i =0,imax = Anims.Length;i<imax;i++)
            {
                Anims[i].Play();
            }
           Delay = Random.Range(MinDelay,MaxDelay);
           mDelay = 0;
        }
        else
        {
            mDelay += Time.deltaTime;
        }
	
	}
}
