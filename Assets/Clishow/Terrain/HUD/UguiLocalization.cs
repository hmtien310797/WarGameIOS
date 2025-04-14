using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class UguiLocalization : MonoBehaviour {

    public string key;

    public string value
    {
        set
        {
            UnityEngine.UI.Text t = transform.GetComponent<UnityEngine.UI.Text>();
            if (t != null) {
                t.text = value;
            }
        }
    }
            // Use this for initialization
    void Start () {
        OnLocalize();
    }
	
	// Update is called once per frame
	void OnLocalize() {
        if (!string.IsNullOrEmpty(key)) value = TextManager.Instance.GetText(key);
    }
}
