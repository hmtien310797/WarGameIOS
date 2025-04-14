using UnityEngine;
using System.Collections;

public class MainCity : SceneEntity
{
    public GameObject mainCityPrefab;
    new void Awake()
    {
        var mainCityGameObject = Instantiate(mainCityPrefab) as GameObject;
        mainCityGameObject.transform.SetParent(transform);
        mainCityGameObject.name = "maincity";
        mainCityGameObject.AddComponent<LuaBehaviour>();
    }

    new void Start()
    {
        SceneManager.instance.Entity = this;
        if (combinedModel)
        {
            StaticBatchingUtility.Combine(combinedModel.gameObject);
        }
        StartCoroutine(InitShadow(false));
    }

    public void OnDestroy()
    {
        mainCityPrefab = null;
        GameStateMain.Instance.ClearMainCity();
    }
}
