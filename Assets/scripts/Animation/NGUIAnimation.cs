using UnityEngine;
using System.Collections;

/* 
 * This script is used for NGUI animations, like transform animation, color, alpha
 * */

[AddComponentMenu("Animation/NGUI Animation")]
public sealed class NGUIAnimation : TimescaleIndependentAnimation 
{
	public bool playAutomatically = true;
	public bool restoreAfterAnimationEnd = false;
	
	/* Animation Properties Except Transform.
	 * Transform animation can be edit in Animation Editor self
	 * Other animations' proterties setting here*/
	public bool animatedColor = true;
	public bool animatedAlpha = true;
	public Color colorTint = Color.white;

	//public bool animatedAdditiveColor = false;
	//public Color colorAdditive = Color.clear;

	private UIWidget element;
	private Color firstColor;

	private bool mStarted = false;
	
	void Awake()
	{
		element = GetComponent<UIWidget>();
		if (element != null)
		{
			enabled = true;
		}
		else
		{
			enabled = false;
			return;
		}

		firstColor = colorTint;
	}
	
	void Start()
	{
		if (playAutomatically && !_animating) 
		{
			Play();

			if (element != null)
			{
				if (animatedAlpha)
				{
					element.alpha = firstColor.a;
				}
				if (animatedColor)
				{
					element.color = firstColor;
				}
			}
		}
		mStarted = true;
	}
	
	void OnEnable()
	{
		if (mStarted && playAutomatically && !_animating)
		{
			Play();
			
			if (element != null)
			{
				if (animatedAlpha)
				{
					element.alpha = firstColor.a;
				}
				if (animatedColor)
				{
					element.color = firstColor;
				}
			}
		}
	}
	
	void OnDisable()
	{
		// remove this for hud bug cannot trigger animation complete callback
		//if (_animating)
		//{
		//	Stop();
		//}
	}
	
	protected override void Update()
	{
		if (_animating)
		{
			// Update the animation
			base.Update();
			
			if (element == null)
				return;
			
			// still animating
			if (_animating)
			{
				// only change the alpha
				if (animatedAlpha)
				{
					element.alpha = colorTint.a;
				}

				// use the animated color
				if (animatedColor)
				{
					element.color = colorTint;
				}
				
				// use the animated Additive color
				//if (animatedAdditiveColor)
				//{
				//	element.SetAdditive(_colorAdditive);
				//}
			}
		}
	}
	
	/**
		This function is overridden and calls the method Element2D.AnimationCompleted().	
	*/
	sealed override protected void OnAnimationComplete()
	{
		base.OnAnimationComplete();

		/*if (element)
		{
			// if true, restore the material to the shared one
			if (restoreAfterAnimationEnd && (animatedColor || animatedAdditiveColor))
			{
				element.Restore();
			}
			element.OnAnimationComplete();
		}*/
	}
	
	sealed override protected void OnAnimationStop()
	{
		base.OnAnimationStop();

		/*if (element)
		{
			if (restoreAfterAnimationEnd && (animatedColor || animatedAdditiveColor))
			{
				element.Restore();
			}
		}*/
	}
}
