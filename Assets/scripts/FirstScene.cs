using UnityEngine;
using System.Collections;

public class FirstScene : MonoBehaviour {

	// Use this for initialization
	void Start () {
        UnityEngine.SceneManagement.SceneManager.LoadSceneAsync("Main", UnityEngine.SceneManagement.LoadSceneMode.Single);
    }
	
	// Update is called once per frame
	void Update () {
	
	}
}
