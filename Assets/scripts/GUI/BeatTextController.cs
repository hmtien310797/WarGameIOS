using UnityEngine;
using System.Collections;

public class BeatTextController : MonoBehaviour
{
    public Animation Anim;

    void Update()
    {
        if(!Anim.isPlaying)
        {
            Destroy(this.gameObject);
        }
    }
}
//    public bool isElastic = false;
//    public float NormalSize = 1;
//    public float BigSize;
//    public float Right =1 ;
//    public float Height;
//    public float TotalTime;
//    public System.Action OnFinish;
//    private Transform mTrf;

//    public Transform Trf
//    {
//        get
//        {
//            if(mTrf == null)
//                mTrf = this.transform;
//            return mTrf;
//        }
//    }

//    private Vector3 mStartPos;
//    private Vector3 mHeigtPos;
//    private Vector3 mEndPos;
//    private UILabel mLable;
//    private float mTime = 0;

//    public void Start()
//    {
//        mStartPos = Trf.localPosition;
//        mHeigtPos = Trf.localPosition +Vector3.up*Height+Vector3.right*Right;
//        mEndPos = Trf.localPosition + 1.5f*Vector3.down*Height+Vector3.right*Right*2f;
//        mLable = GetComponent<UILabel>();
//        mLable.alpha = 1f;
//        Trf.localScale = Vector3.one*NormalSize;
//        mTime = 0;
//    }

//    void UpdateMove(float t)
//    {
//        float p = t/TotalTime;
//        if(p >= 1)
//        {
//            if(OnFinish != null)
//                OnFinish();
//            Destroy(this.gameObject);
//        }
//        else
//        {
//            float f;
//            if(p<=0.5f)
//            {
//                float fp = p / 0.5f;
//                f = easeOutCirc(0,1,fp);
//                Vector3 pos = Vector3.Lerp(mStartPos,mHeigtPos, fp);
//                pos.y = f*(mHeigtPos.y - mStartPos.y )+mStartPos.y;
//                Trf.localPosition = pos;
//                float ff = (!isElastic?easeOutBack(NormalSize,BigSize,f):(easeOutElastic(NormalSize,BigSize,fp)));//Mathf.Max(0,(fp-0.5f)/0.5f))
//                Trf.localScale  = Vector3.one*ff;
//            }
//            else
//            {
//                float fp = (p-0.5f)/0.5f;
//                f = easeInCirc(0,1,fp);
//                Vector3 pos =  Vector3.Lerp(mHeigtPos,mEndPos, fp);
//                pos.y = f*(mEndPos.y - mHeigtPos.y )+mHeigtPos.y;
//                Trf.localPosition = pos;
//                mLable.alpha = easeInCubic(1,0.001f,fp);
//                Trf.localScale  = (Vector3.one*easeInCubic(BigSize,NormalSize,fp));
//            }
//        }
//    }

//    public void Update()
//    {
//        mTime += Time.deltaTime;
//        UpdateMove(mTime);
//    }

//	private float easeInCirc(float start, float end, float value){
//		end -= start;
//		return -end * (Mathf.Sqrt(1 - value * value) - 1) + start;
//	}

//	private float easeOutCirc(float start, float end, float value){
//		value--;
//		end -= start;
//		return end * Mathf.Sqrt(1 - value * value) + start;
//	}
//	private float easeInCubic(float start, float end, float value){
//		end -= start;
//		return end * value * value * value + start;
//	}
//	private float easeOutCubic(float start, float end, float value){
//		value--;
//		end -= start;
//		return end * (value * value * value + 1) + start;
//	}

//	private float easeOutQuad(float start, float end, float value){
//		end -= start;
//		return -end * value * (value - 2) + start;
//	}

//	private float easeOutBack(float start, float end, float value){
//		float s = 1.70158f;
//		end -= start;
//		value = (value) - 1;
//		return end * ((value) * value * ((s + 1) * value + s) + 1) + start;
//	}

//	private float easeOutElastic(float start, float end, float value){
//	/* GFX47 MOD END */
//		//Thank you to rafael.marteleto for fixing this as a port over from Pedro's UnityTween
//		end -= start;
		
//		float d = 1f;
//		float p = d * .3f;
//		float s = 0;
//		float a = 0;
		
//		if (value == 0) return start;
		
//		if ((value /= d) == 1) return start + end;
		
//		if (a == 0f || a < Mathf.Abs(end)){
//			a = end;
//			s = p * 0.25f;
//			}else{
//			s = p / (2 * Mathf.PI) * Mathf.Asin(end / a);
//		}
		
//		return (a * Mathf.Pow(2, -10 * value) * Mathf.Sin((value * d - s) * (2 * Mathf.PI) / p) + end + start);
//	}	
//}
