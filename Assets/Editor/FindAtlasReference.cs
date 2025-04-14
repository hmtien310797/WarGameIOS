using UnityEngine;
using System.Collections;
using UnityEditor;
using System.Collections.Generic;
using System.IO;

public class FindAtlasReference : EditorWindow
{
    static public FindAtlasReference instance;
    Vector2 mScroll = Vector2.zero;
    public Dictionary<string, BetterList<string>> dict;

    void OnEnable() { instance = this; }
    void OnDisable() { instance = null; }
    string atlasName = string.Empty;
    string sprName = string.Empty;
    static string targetName = string.Empty;
    BetterList<GameObject> findResult = new BetterList<GameObject>();

    void OnGUI()
    {
        
        if (dict == null)
        {
            return;
        }
        
        GUILayout.Space(20);
        mScroll = GUILayout.BeginScrollView(mScroll);
        BetterList<string> list = dict["prefab"];
        if (list != null && list.size > 0)
        {
            GUILayout.Label("target:" + targetName);
            atlasName = EditorGUILayout.TextField("查找atlasName:", atlasName);
            
            sprName = EditorGUILayout.TextField("查找SpriteName:", sprName);

            if (GUILayout.Button("find sprite"))  //在窗口上创建一个按钮  
            {
                findResult.Clear();
                targetName = atlasName;
                foreach (string item in list)
                {
                    GameObject go = AssetDatabase.LoadAssetAtPath(item, typeof(GameObject)) as GameObject;
                    UISprite[] sps = go.GetComponentsInChildren<UISprite>(true);
                    for(int i=0; i<sps.Length;i++)
                    {
                        if (sps[i].atlas == null || sps[i].spriteName == null)
                        {
                            GUILayout.Label("null path:" + GetGameObjectPath(sps[i].gameObject));
                            Debug.Log("sps is null");
                            continue;
                        }
                        if (sps[i].atlas.name == atlasName && sps[i].spriteName == sprName)
                        {
                            findResult.Add(sps[i].gameObject);
                            //Debug.Log(sps[i].atlas.name + "  " + GetGameObjectPath(sps[i].gameObject) + "  " + sps[i].spriteName);
                        }
                    }
                }
            }
            if (NGUIEditorTools.DrawHeader("Prefab"))
            {
                foreach (string item in list)
                {
                    GameObject go = AssetDatabase.LoadAssetAtPath(item, typeof(GameObject)) as GameObject;
                    EditorGUILayout.ObjectField("Prefab", go, typeof(GameObject), false);

                }
            }
            list = null;
        }

        list = dict["fbx"];
        if (list != null && list.size > 0)
        {
            if (NGUIEditorTools.DrawHeader("FBX"))
            {
                foreach (string item in list)
                {
                    GameObject go = AssetDatabase.LoadAssetAtPath(item, typeof(GameObject)) as GameObject;
                    EditorGUILayout.ObjectField("FBX", go, typeof(GameObject), false);

                }
            }
            list = null;
        }

        list = dict["cs"];
        if (list != null && list.size > 0)
        {
            if (NGUIEditorTools.DrawHeader("Script"))
            {
                foreach (string item in list)
                {
                    MonoScript go = AssetDatabase.LoadAssetAtPath(item, typeof(MonoScript)) as MonoScript;
                    EditorGUILayout.ObjectField("Script", go, typeof(MonoScript), false);

                }
            }
            list = null;
        }

        list = dict["texture"];
        if (list != null && list.size > 0)
        {
            if (NGUIEditorTools.DrawHeader("Texture"))
            {
                foreach (string item in list)
                {
                    Texture2D go = AssetDatabase.LoadAssetAtPath(item, typeof(Texture2D)) as Texture2D;
                    EditorGUILayout.ObjectField("Texture:" + go.name, go, typeof(Texture2D), false);

                }
            }
            list = null;
        }

        list = dict["mat"];
        if (list != null && list.size > 0)
        {
            if (NGUIEditorTools.DrawHeader("Material"))
            {
                foreach (string item in list)
                {
                    Material go = AssetDatabase.LoadAssetAtPath(item, typeof(Material)) as Material;
                    EditorGUILayout.ObjectField("Material", go, typeof(Material), false);

                }
            }
            list = null;
        }

        list = dict["shader"];
        if (list != null && list.size > 0)
        {
            if (NGUIEditorTools.DrawHeader("Shader"))
            {
                foreach (string item in list)
                {
                    Shader go = AssetDatabase.LoadAssetAtPath(item, typeof(Shader)) as Shader;
                    EditorGUILayout.ObjectField("Shader", go, typeof(Shader), false);
                }
            }
            list = null;
        }

        list = dict["font"];
        if (list != null && list.size > 0)
        {
            if (NGUIEditorTools.DrawHeader("Font"))
            {
                foreach (string item in list)
                {
                    Font go = AssetDatabase.LoadAssetAtPath(item, typeof(Font)) as Font;
                    EditorGUILayout.ObjectField("Font", go, typeof(Font), false);
                }
            }
            list = null;
        }

        list = dict["anim"];
        if (list != null && list.size > 0)
        {
            if (NGUIEditorTools.DrawHeader("Animation"))
            {
                foreach (string item in list)
                {
                    AnimationClip go = AssetDatabase.LoadAssetAtPath(item, typeof(AnimationClip)) as AnimationClip;
                    EditorGUILayout.ObjectField("Animation:", go, typeof(AnimationClip), false);
                }
            }
            list = null;
        }

        list = dict["animTor"];
        if (list != null && list.size > 0)
        {
            if (NGUIEditorTools.DrawHeader("Animator"))
            {
                foreach (string item in list)
                {
                    //Animator go = AssetDatabase.LoadAssetAtPath(item, typeof(Animator)) as Animator;
                    //EditorGUILayout.ObjectField("Animator:", go, typeof(Animator), true);
                    EditorGUILayout.LabelField(item);
                }
            }
            list = null;
        }

        list = dict["level"];
        if (list != null && list.size > 0)
        {
            if (NGUIEditorTools.DrawHeader("Level"))
            {
                foreach (string item in list)
                {
                    //SceneView go = AssetDatabase.LoadAssetAtPath(item, typeof(SceneView)) as SceneView;
                    EditorGUILayout.LabelField(item);
                    //SceneView go = AssetDatabase.LoadAssetAtPath(item, typeof(SceneView)) as SceneView;
                    //EditorGUILayout.ObjectField("Animation:" , go, typeof(SceneView), true);
                }
            }
            list = null;
        }


        if (findResult != null && findResult.size > 0)
        {
            if (NGUIEditorTools.DrawHeader("find result"))
            {
                foreach (var item in findResult)
                {
                    EditorGUILayout.ObjectField("Prefab", item, typeof(GameObject), false);
                    GUILayout.Space(20);
                    GUILayout.Label("path:" + GetGameObjectPath(item));
                    //Debug.Log(sps[i].atlas.name + "  " + GetGameObjectPath(sps[i].gameObject) + "  " + sps[i].spriteName);
                }
            }
        }
        GUILayout.EndScrollView();
    }

    /// <summary>
    /// 依据脚本查找引用的对象
    /// </summary>
    [MenuItem("Assets/Wiker/Find Script Reference", false, 0)]
    static public void FindScriptReference()
    {
        //EditorWindow.GetWindow<UIAtlasMaker>(false, "Atlas Maker", true).Show();
        //Debug.Log("Selected Transform is on " + Selection.activeObject.name + ".");
        //foreach(string guid in Selection.assetGUIDs){

        //    Debug.Log("GUID " + guid);

        //}
        targetName = Selection.activeObject.name;
        ShowProgress(0, 0, 0);
        string curPathName = AssetDatabase.GetAssetPath(Selection.activeObject.GetInstanceID());

        Dictionary<string, BetterList<string>> dic = new Dictionary<string, BetterList<string>>();
        BetterList<string> prefabList = new BetterList<string>();
        BetterList<string> fbxList = new BetterList<string>();
        BetterList<string> scriptList = new BetterList<string>();
        BetterList<string> textureList = new BetterList<string>();
        BetterList<string> matList = new BetterList<string>();
        BetterList<string> shaderList = new BetterList<string>();
        BetterList<string> fontList = new BetterList<string>();
        BetterList<string> levelList = new BetterList<string>();

        string[] allGuids = AssetDatabase.FindAssets("t:Prefab t:Scene", new string[] { "Assets" });
        int i = 0;
        foreach (string guid in allGuids)
        {
            string assetPath = AssetDatabase.GUIDToAssetPath(guid);
            string[] names = AssetDatabase.GetDependencies(new string[] { assetPath });  //依赖的东东
            foreach (string name in names)
            {
                if (name.Equals(curPathName))
                {
                    //Debug.Log("Refer:" + assetPath);
                    if (assetPath.EndsWith(".prefab"))
                    {
                        prefabList.Add(assetPath);
                        break;
                    }
                    else if (assetPath.ToLower().EndsWith(".fbx"))
                    {
                        fbxList.Add(assetPath);
                        break;
                    }
                    else if (assetPath.ToLower().EndsWith(".unity"))
                    {
                        levelList.Add(assetPath);
                        break;
                    }
                    else if (assetPath.EndsWith(".cs"))
                    {
                        scriptList.Add(assetPath);
                        break;
                    }
                    else if (assetPath.EndsWith(".png"))
                    {
                        textureList.Add(assetPath);
                        break;
                    }
                    else if (assetPath.EndsWith(".mat"))
                    {
                        matList.Add(assetPath);
                        break;
                    }
                    else if (assetPath.EndsWith(".shader"))
                    {
                        shaderList.Add(assetPath);
                        break;
                    }
                    else if (assetPath.EndsWith(".ttf"))
                    {
                        fontList.Add(assetPath);
                        break;
                    }
                }
            }
            ShowProgress((float)i / (float)allGuids.Length, allGuids.Length, i);
            i++;
        }

        dic.Add("prefab", prefabList);
        dic.Add("fbx", fbxList);
        dic.Add("cs", scriptList);
        dic.Add("texture", textureList);
        dic.Add("mat", matList);
        dic.Add("shader", shaderList);
        dic.Add("font", fontList);
        dic.Add("level", levelList);
        dic.Add("anim", null);
        dic.Add("animTor", null);
        EditorUtility.ClearProgressBar();
        EditorWindow.GetWindow<FindAtlasReference>(false, "Object Reference", true).Show();

        //foreach (KeyValuePair<string, BetterList<string>> d in dic)
        //{
        //    foreach (string s in d.Value)
        //    {
        //        Debug.Log(d.Key + "=" + s);
        //    }
        //}

        if (FindAtlasReference.instance.dict != null) FindAtlasReference.instance.dict.Clear();
        FindAtlasReference.instance.dict = dic;

        //string[] path = new string[1];
        //path[0] = AssetDatabase.GetAssetPath(Selection.activeObject.GetInstanceID());
        //string[] names = AssetDatabase.GetDependencies(path);  //依赖的东东
        //foreach (string name in names)
        //{
        //    Debug.Log("Name:"+name);
        //}


    }

    public static void ShowProgress(float val, int total, int cur)
    {
        EditorUtility.DisplayProgressBar("Searching", string.Format("Finding ({0}/{1}), please wait...", cur, total), val);
    }

    /// <summary>
    /// 查找对象引用的类型
    /// </summary>
    [MenuItem("Assets/Wiker/Find Object Dependencies", false, 0)]
    public static void FindObjectDependencies()
    {

        ShowProgress(0, 0, 0);
        Dictionary<string, BetterList<string>> dic = new Dictionary<string, BetterList<string>>();
        BetterList<string> prefabList = new BetterList<string>();
        BetterList<string> fbxList = new BetterList<string>();
        BetterList<string> scriptList = new BetterList<string>();
        BetterList<string> textureList = new BetterList<string>();
        BetterList<string> matList = new BetterList<string>();
        BetterList<string> shaderList = new BetterList<string>();
        BetterList<string> fontList = new BetterList<string>();
        BetterList<string> animList = new BetterList<string>();
        BetterList<string> animTorList = new BetterList<string>();
        string curPathName = AssetDatabase.GetAssetPath(Selection.activeObject.GetInstanceID());
        string[] names = AssetDatabase.GetDependencies(new string[] { curPathName });  //依赖的东东
        int i = 0;
        foreach (string name in names)
        {
            if (name.EndsWith(".prefab"))
            {
                prefabList.Add(name);
            }
            else if (name.ToLower().EndsWith(".fbx"))
            {
                fbxList.Add(name);
            }
            else if (name.EndsWith(".cs"))
            {
                scriptList.Add(name);
            }
            else if (name.EndsWith(".png"))
            {
                textureList.Add(name);
            }
            else if (name.EndsWith(".mat"))
            {
                matList.Add(name);
            }
            else if (name.EndsWith(".shader"))
            {
                shaderList.Add(name);
            }
            else if (name.EndsWith(".ttf"))
            {
                fontList.Add(name);
            }
            else if (name.EndsWith(".anim"))
            {
                animList.Add(name);
            }
            else if (name.EndsWith(".controller"))
            {
                animTorList.Add(name);
            }
            Debug.Log("Dependence:" + name);
            ShowProgress((float)i / (float)names.Length, names.Length, i);
            i++;
        }

        dic.Add("prefab", prefabList);
        dic.Add("fbx", fbxList);
        dic.Add("cs", scriptList);
        dic.Add("texture", textureList);
        dic.Add("mat", matList);
        dic.Add("shader", shaderList);
        dic.Add("font", fontList);
        dic.Add("level", null);
        dic.Add("animTor", animTorList);
        dic.Add("anim", animList);
        //deps.Sort(Compare);
        EditorWindow.GetWindow<FindAtlasReference>(false, "Object Dependencies", true).Show();
        if (FindAtlasReference.instance.dict != null) FindAtlasReference.instance.dict.Clear();
        FindAtlasReference.instance.dict = dic;
        EditorUtility.ClearProgressBar();
    }


    public static string GetGameObjectPath(GameObject obj)
    {
        string path = "/" + obj.name;
        while (obj.transform.parent != null)
        {
            obj = obj.transform.parent.gameObject;
            path = "/" + obj.name + path;
        }
        return path;
    }

    public void Close()
    {
        findResult.Clear();
        findResult = null;
        atlasName = string.Empty;
        sprName = string.Empty;
         targetName = string.Empty;
    }
}
