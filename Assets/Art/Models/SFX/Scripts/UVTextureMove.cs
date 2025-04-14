using UnityEngine;
using System.Collections;

public class UVTextureMove : MonoBehaviour
{
	//UVTraget
	public UITexture uiTexture;

	//Speed
	public float speedX = 0.1f;
	public float speedY = 0.1f;

	private float offset_x = 0.0f;
	private float offset_y = 0.0f;
	private float uv_w = 0;
	private float uv_h = 0;

	void Start()
	{
		if (uiTexture == null) {
			uiTexture = gameObject.GetComponent<UITexture>();
		}

		if (uiTexture == null) {
			Debug.LogError("UITexture not exist!");
		}

		uv_w = uiTexture.uvRect.width;
		uv_h = uiTexture.uvRect.height;
	}

	void Update ()
	{
		offset_x += Time.deltaTime * speedX;
		offset_y += Time.deltaTime * speedY;

		uiTexture.uvRect = new Rect(offset_x, offset_y, uv_w, uv_h);
	}
}