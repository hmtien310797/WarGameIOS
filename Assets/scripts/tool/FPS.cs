using UnityEngine;
using System.Collections;

// Attach this to a GUIText to make a frames/second indicator.
//
// It calculates frames/second over each updateInterval,
// so the display does not keep changing wildly.
//
// It is also fairly accurate at very low FPS counts (<10).
// We do this not by simply counting frames per interval, but
// by accumulating FPS for each frame. This way we end up with
// correct overall FPS even if the interval renders something like
// 5.5 frames.
public class FPS : MonoBehaviour
{
	public float updateInterval = 0.5f;	
	private float accum = 0.0f; // FPS accumulated over the interval
	private float frames = 0; // Frames drawn over the interval
	private float timeleft; // Left time for current interval
	string info;

    private UILabel label;

	void Start()
	{		
		timeleft = updateInterval;
        label = GetComponent<UILabel>();
        if (GameEnviroment.NETWORK_ENV == GameEnviroment.EEnviroment.eDist)
        {
            gameObject.SetActive(false);
        }
    }

    void Update()
    {
        timeleft -= Serclimax.GameTime.realDeltaTime;
        accum += 1 / Serclimax.GameTime.realDeltaTime;
        ++frames;

        // Interval ended - update GUI text and start new interval
        if (timeleft <= 0.0f)
        {
            // display two fractional digits (f2 format)
            string info = (accum / frames).ToString("f0");
            if (label)
                label.text = info;
            timeleft = updateInterval;
            accum = 0.0f;
            frames = 0;
        }
    }
}