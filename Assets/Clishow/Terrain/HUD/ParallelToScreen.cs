using UnityEngine;
using System.Collections;

public class ParallelToScreen : MonoBehaviour {

	// Use this for initialization
	void Start () {
        Vector3 zoom = this.gameObject.transform.parent.localScale;
        this.gameObject.transform.localScale = new Vector3(1 / zoom.x, 1 / zoom.y, 1 / zoom.z);
        this.transform.forward = new Vector3(1, -1, 1);
    }
}
