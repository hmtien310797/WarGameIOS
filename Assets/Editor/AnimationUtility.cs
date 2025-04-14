using UnityEditor;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;

public class AnimationUtility : EditorWindow
{
    class ExportSetting
    {
        public string exportPath;
        public string exportName;
        public Vector3 scale;
        public string layer;
        public string defaultClip;
        public bool playAutomaically;
        public AnimationCullingType cullType;

        public bool extraExport1 = false;
        public ExportSetting setting1;

        public string shareAnimModel;
        public string shareAnimPath;
    }


    static AnimationUtility createrWindow;

    [MenuItem("Tools/Export Animation")]
    static void CreateAnimationClip()
    {
        createrWindow = (AnimationUtility)EditorWindow.GetWindow(typeof(AnimationUtility));
        createrWindow.openAnimClip();
    }

    void ShowModelSetting(int _mode)
    {
        if (setting == null)
            return;

        List<DirectoryInfo> lstDir = null;
        if (_mode == 1)
        {
            lstDir = mBuildDirInfo;
        }
        else if (_mode == 2)
        {
            lstDir = mModelDirInfo;
        }
		else if (_mode == 3)
		{
            lstDir = mConstructDirInfo;
		}

        EditorGUILayout.LabelField("Animation Clip Setting", EditorStyles.boldLabel);

        GUILayout.Space(20);

        setting.exportName = EditorGUILayout.TextField("Prefab name:", setting.exportName);
        setting.exportPath = EditorGUILayout.TextField("Prefab path:", setting.exportPath);
        setting.scale = EditorGUILayout.Vector3Field("Prefab scale:", setting.scale);
        setting.layer = EditorGUILayout.TextField("Prefab layer:", setting.layer);
        setting.defaultClip = EditorGUILayout.TextField("Default clip:", setting.defaultClip);
        setting.playAutomaically = EditorGUILayout.Toggle("Play Automatically:", setting.playAutomaically);
        setting.cullType = (AnimationCullingType)EditorGUILayout.EnumPopup("Culling type:", setting.cullType);

        GUILayout.Space(10);
        setting.extraExport1 = EditorGUILayout.Toggle("Extra export:", setting.extraExport1);
        if (setting.extraExport1)
        {
            GUI.color = Color.yellow;

            setting.setting1.exportName = EditorGUILayout.TextField("Prefab name:", setting.setting1.exportName);
            setting.setting1.exportPath = EditorGUILayout.TextField("Prefab path:", setting.setting1.exportPath);
            setting.setting1.scale = EditorGUILayout.Vector3Field("Prefab scale:", setting.setting1.scale);
            setting.setting1.layer = EditorGUILayout.TextField("Prefab layer:", setting.setting1.layer);
            setting.setting1.defaultClip = EditorGUILayout.TextField("Default clip:", setting.setting1.defaultClip);
            setting.setting1.playAutomaically = EditorGUILayout.Toggle("Play Automatically:", setting.setting1.playAutomaically);
            setting.setting1.cullType = (AnimationCullingType)EditorGUILayout.EnumPopup("Culling type:", setting.setting1.cullType);

            GUI.color = Color.white;
        }

        GUILayout.Space(10);

        setting.shareAnimModel = EditorGUILayout.TextField("Basic Animation name:", setting.shareAnimModel);
        setting.shareAnimPath = EditorGUILayout.TextField("Basic Animation directory:", setting.shareAnimPath);

        GUILayout.Space(20);
        if (GUILayout.Button("Export"))
        {
            ExportAnimClip(lstDir[selectedDirIndex], setting);
        }
        GUILayout.Space(10);
        if (GUILayout.Button("Export For UI"))
        {
            ExportAnimClipForUI(lstDir[selectedDirIndex], setting);
        }

        GUILayout.Space(20);
        if (GUILayout.Button("Back"))
        {
            selectedDirIndex = -1;
        }
    }

    Vector2 scrollPosition = Vector2.zero;
    void ShowModelDir(int _mode)
    {
        List<DirectoryInfo> lstDir = null;
        if (_mode == 1)
        {
            lstDir = mBuildDirInfo;
        }
        else if (_mode == 2)
        {
            lstDir = mModelDirInfo;
        }
		else if (_mode == 3)
		{
			lstDir = mConstructDirInfo;
		}

        EditorGUILayout.LabelField("Animation Clip", EditorStyles.boldLabel);

        scrollPosition = GUILayout.BeginScrollView(scrollPosition);
        bool bBreak = false;
        GUILayout.BeginVertical();
        for (int i = 0; i < 40; i++)
        {
            GUILayout.BeginHorizontal();
            for (int j = 0; j < 5; j++)
            {
                int idx = 5 * i + j;
                if (idx < lstDir.Count)
                {
                    if (GUILayout.Button(lstDir[idx].Name, GUILayout.Width(180), GUILayout.Height(28)))
                    {
                        selectedDirIndex = idx;
                        bBreak = true;
                        break;
                    }
                }
                else
                {
                    bBreak = true;
                    break;
                }
            }
            GUILayout.EndHorizontal();

            if (bBreak)
                break;
        }
        GUILayout.EndVertical();
        GUILayout.EndScrollView();

        GUILayout.Space(50);

        if (GUILayout.Button("Back", GUILayout.Width(180), GUILayout.Height(28)))
        {
            selectedDirIndex = -1;
            selectedMode = 0;
        }

        if (selectedDirIndex >= 0)
        {
            setting = GetExportSetting(selectedMode);
        }
    }

    void OnGUI()
    {
        if (selectedMode == 0)
        {
            EditorGUILayout.LabelField("Animation Clip", EditorStyles.boldLabel);

            GUILayout.BeginHorizontal();

            if (GUILayout.Button("Defends", GUILayout.Width(180), GUILayout.Height(28)))
            {
                selectedMode = 1;
            }
            GUILayout.Space(20);

            if (GUILayout.Button("Units", GUILayout.Width(180), GUILayout.Height(28)))
            {
                selectedMode = 2;
            }
			
			if (GUILayout.Button("Constructs", GUILayout.Width(180), GUILayout.Height(28)))
            {
                selectedMode = 3;
            }

            GUILayout.EndHorizontal();
        }
        else
        {
            if (selectedDirIndex >= 0)
            {
                ShowModelSetting(selectedMode);
            }
            else
            {
                ShowModelDir(selectedMode);
            }
        }
    }

    /// <summary>
    /// animation exporter
    /// </summary>
    /// 
    int selectedMode = 0;   //0:default 1:build 2:unit

    int selectedDirIndex;
    ExportSetting setting;
    
    static readonly string UNIT_ROOT_PATH = "Assets/Art/Models/Unit/";
    List<DirectoryInfo> mModelDirInfo = new List<DirectoryInfo>();

    static readonly string BUILD_ROOT_PATH = "Assets/Art/Models/Defends/";
    List<DirectoryInfo> mBuildDirInfo = new List<DirectoryInfo>();

	static readonly string CONSTRUCT_ROOT_PATH = "Assets/Art/Models/Constructs/";
    List<DirectoryInfo> mConstructDirInfo = new List<DirectoryInfo>();
	
    void closeAnimClip()
    {
        mModelDirInfo.Clear();
		mBuildDirInfo.Clear();
		mConstructDirInfo.Clear();
    }

    void openAnimClip()
    {
        selectedDirIndex = -1;

        DirectoryInfo dirRoot = new DirectoryInfo(UNIT_ROOT_PATH);
        DirectoryInfo[] dirChild = dirRoot.GetDirectories();

        for (int i = 0; i < dirChild.Length; i++)
        {
            if (dirChild[i].Name.Contains("Materials"))
                continue;

            mModelDirInfo.Add(dirChild[i]);
        }

        dirRoot = new DirectoryInfo(BUILD_ROOT_PATH);
        dirChild = dirRoot.GetDirectories();

        for (int i = 0; i < dirChild.Length; i++)
        {
            if (dirChild[i].Name.Contains("Materials"))
                continue;

            mBuildDirInfo.Add(dirChild[i]);
        }
		
		dirRoot = new DirectoryInfo(CONSTRUCT_ROOT_PATH);
        dirChild = dirRoot.GetDirectories();

        for (int i = 0; i < dirChild.Length; i++)
        {
            if (dirChild[i].Name.Contains("Materials"))
                continue;

            mConstructDirInfo.Add(dirChild[i]);
        }
    }

    List<string> GetRemainAnimations(string _layerName, string _name)
    {
        List<string> results = new List<string>();

        results.Add("idle");
        results.Add("idle1");

        if (_layerName == "units")
        {
            /*if (_name.Contains("mushi"))
            {
                results.Add("skill_in");
                results.Add("skill_loop");
                results.Add("skill_out");
            }
            else*/
            {
                results.Add("attack");
                results.Add("attack1");
                results.Add("standby");
            }

            results.Add("victory");
            results.Add("victory_loop");
        }

        return results;
    }

    void ExportAnimClipForUI(DirectoryInfo _dir, ExportSetting _setting)
    {
        if (_dir == null || _setting == null)
            return;

        GameObject mainObject = null;
        Animation objAnim = null;

        GameObject prefab = AssetDatabase.LoadMainAssetAtPath(_setting.exportPath + _setting.exportName + ".prefab") as GameObject;
        if (prefab)
        {
            mainObject = Object.Instantiate(prefab) as GameObject;

            if (mainObject != null)
            {
                objAnim = mainObject.GetComponent<Animation>();

                //////////////////////////////////////////////////////////////////////////////////////////////////////////////
                // Create For UI

                List<string> remainAnims = GetRemainAnimations(_setting.layer, _setting.exportName);
                List<string> removeAnims = new List<string>();
                foreach (AnimationState clip in objAnim)
                {
                    if (!remainAnims.Contains(clip.name))
                    {
                        removeAnims.Add(clip.name);
                    }
                }
                for (int i = 0; i < removeAnims.Count; i++)
                {
                    objAnim.RemoveClip(removeAnims[i]);
                }

                PrefabUtility.CreatePrefab(_setting.exportPath + _setting.exportName + "_UI.prefab", mainObject);

                Object.DestroyImmediate(mainObject);
                mainObject = null;
            }
            //////////////////////////////////////////////////////////////////////////////////////////////////////////////
        }


        if (_setting.extraExport1)
        {
            prefab = AssetDatabase.LoadMainAssetAtPath(_setting.setting1.exportPath + _setting.setting1.exportName + ".prefab") as GameObject;

            if (prefab)
            {
                mainObject = Object.Instantiate(prefab) as GameObject;
                if (mainObject != null)
                {
                    objAnim = mainObject.GetComponent<Animation>();

                    //////////////////////////////////////////////////////////////////////////////////////////////////////////////
                    // Create For UI
                    List<string> remainAnims = GetRemainAnimations(_setting.setting1.layer, _setting.setting1.exportName);
                    List<string> removeAnims = new List<string>();
                    foreach (AnimationState clip in objAnim)
                    {
                        if (!remainAnims.Contains(clip.name))
                        {
                            removeAnims.Add(clip.name);
                        }
                    }
                    for (int i = 0; i < removeAnims.Count; i++)
                    {
                        objAnim.RemoveClip(removeAnims[i]);
                    }

                    PrefabUtility.CreatePrefab(_setting.setting1.exportPath + _setting.setting1.exportName + "_UI.prefab", mainObject);

                    Object.DestroyImmediate(mainObject);
                    mainObject = null;
                }
                //////////////////////////////////////////////////////////////////////////////////////////////////////////////
            }
        }

        SaveExportSetting(_dir, _setting);

        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
    }

    void ExportAnimClip(DirectoryInfo _dir, ExportSetting _setting)
    {
        if (_dir == null || _setting == null)
            return;

        GameObject mainObject = null;
        string mainObjectName = "";
        Animation objAnim = null;

        FileInfo[] fileInfo = _dir.GetFiles("*.FBX", SearchOption.TopDirectoryOnly);
        for (int i = 0; i < fileInfo.Length; i++)
        {
            if (fileInfo[i].Name.Contains("@"))
            {
                mainObjectName = fileInfo[i].Name.Remove(fileInfo[i].Name.LastIndexOf("@"));

                int idx = fileInfo[i].FullName.IndexOf("Assets" + Path.DirectorySeparatorChar);
                string fileName = fileInfo[i].FullName.Substring(idx).Replace("" + Path.DirectorySeparatorChar, "/");

                GameObject fbx = AssetDatabase.LoadMainAssetAtPath(fileName.Remove(fileName.LastIndexOf("/")) + "/" + mainObjectName + ".FBX") as GameObject;

                mainObject = Object.Instantiate(fbx) as GameObject;
                mainObject.name = mainObjectName;

                objAnim = mainObject.GetComponent<Animation>();
                break;
            }
        }

        // if we cannot find a animation fbx
        if (mainObject == null)
        {
            for (int i = 0; i < fileInfo.Length; i++)
            {
                mainObjectName = fileInfo[i].Name.Remove(fileInfo[i].Name.LastIndexOf("."));

                int idx = fileInfo[i].FullName.IndexOf("Assets" + Path.DirectorySeparatorChar);
                string fileName = fileInfo[i].FullName.Substring(idx).Replace("" + Path.DirectorySeparatorChar, "/");

                GameObject fbx = AssetDatabase.LoadMainAssetAtPath(fileName.Remove(fileName.LastIndexOf("/")) + "/" + mainObjectName + ".FBX") as GameObject;

                mainObject = Object.Instantiate(fbx) as GameObject;
                mainObject.name = mainObjectName;
                objAnim = mainObject.GetComponent<Animation>();
                break;
            }
        }
        if (mainObject != null)
        {
            // set default animation clip
            foreach (AnimationState clip in objAnim)
            {
                if (clip.name == _setting.defaultClip)
                {
                    objAnim.clip = clip.clip;
                    break;
                }
            }

            // Add Shared Animations
            if (!string.IsNullOrEmpty(_setting.shareAnimModel))
            {
                DirectoryInfo shareDir = null;
                for (int i = 0; i < mModelDirInfo.Count; i++)
                {
                    if (mModelDirInfo[i].Name.EndsWith(_setting.shareAnimPath))
                    {
                        shareDir = mModelDirInfo[i];
                        break;
                    }
                }
                if (shareDir != null)
                {
                    FileInfo[] sharefileInfo = shareDir.GetFiles("*.FBX", SearchOption.TopDirectoryOnly);
                    for (int i = 0; i < sharefileInfo.Length; i++)
                    {
                        if (!sharefileInfo[i].Name.Contains(_setting.shareAnimModel + "@"))
                        {
                            continue;
                        }

                        int idx = sharefileInfo[i].FullName.IndexOf("Assets" + Path.DirectorySeparatorChar);
                        string fileName = sharefileInfo[i].FullName.Substring(idx).Replace("" + Path.DirectorySeparatorChar, "/");
                        GameObject fbx = AssetDatabase.LoadMainAssetAtPath(fileName) as GameObject;
                        if (fbx != null)
                        {
                            Animation anim = fbx.GetComponent<Animation>();
                            if (anim != null)
                            {
                                foreach (AnimationState clip in anim)
                                {
                                    if (clip && clip.clip)
                                    {
                                        if (objAnim != null && objAnim[clip.name] == null)
                                        {
                                            objAnim.AddClip(clip.clip, clip.name);

                                            if (clip.name == _setting.defaultClip)
                                            {
                                                objAnim.clip = clip.clip;
                                            }
                                        }
                                    }
                                }
                            }
                        }

                    }
                }
            }
        }

        if (mainObject != null)
        {
            mainObject.transform.localScale = _setting.scale;
            int layer = LayerMask.NameToLayer(_setting.layer);
            NGUITools.SetLayer(mainObject, layer);

            objAnim.playAutomatically = _setting.playAutomaically;
            objAnim.cullingType = _setting.cullType;

            PrefabUtility.CreatePrefab(_setting.exportPath + _setting.exportName + ".prefab", mainObject);

            if (_setting.extraExport1)
            {
                mainObject.transform.localScale = _setting.setting1.scale;
                int layer1 = LayerMask.NameToLayer(_setting.setting1.layer);
                NGUITools.SetLayer(mainObject, layer1);

                objAnim.playAutomatically = _setting.setting1.playAutomaically;
                objAnim.cullingType = _setting.setting1.cullType;

                PrefabUtility.CreatePrefab(_setting.setting1.exportPath + _setting.setting1.exportName + ".prefab", mainObject);
            }

            Object.DestroyImmediate(mainObject);
            mainObject = null;

            SaveExportSetting(_dir, _setting);

            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
        }
    }

    void SaveExportSetting(DirectoryInfo _dir, ExportSetting _setting)
    {
        string param;

        Dictionary<string, object> data = new Dictionary<string, object>();
        data["name"] = _setting.exportName;
        data["path"] = _setting.exportPath;
        data["sx"] = _setting.scale.x.ToString();
        data["sy"] = _setting.scale.y.ToString();
        data["sz"] = _setting.scale.z.ToString();
        data["layer"] = _setting.layer;
        data["clip"] = _setting.defaultClip;
        data["auto"] = _setting.playAutomaically ? 1 : 0;
        data["cull"] = (long)_setting.cullType;

        if (_setting.extraExport1)
        {
            data["extra1"] = _setting.extraExport1 ? 1 : 0;
            data["name1"] = _setting.setting1.exportName;
            data["path1"] = _setting.setting1.exportPath;
            data["sx1"] = _setting.setting1.scale.x.ToString();
            data["sy1"] = _setting.setting1.scale.y.ToString();
            data["sz1"] = _setting.setting1.scale.z.ToString();
            data["layer1"] = _setting.setting1.layer;
            data["clip1"] = _setting.setting1.defaultClip;
            data["auto1"] = _setting.setting1.playAutomaically ? 1 : 0;
            data["cull1"] = (long)_setting.setting1.cullType;
        }

        data["sharename"] = _setting.shareAnimModel;
        data["sharepath"] = _setting.shareAnimPath;

        param = OurMiniJSON.Json.Serialize(data);

        FileStream fs = new FileStream(_dir.FullName + "/setting.bin", FileMode.Create);
        BinaryWriter bw = new BinaryWriter(fs, Encoding.Unicode);

        bw.Write(param);

        fs.Flush();
        fs.Close();
        bw.Close();
    }

    ExportSetting GetExportSetting(int _mode)
    {
        List<DirectoryInfo> lstDir = null;
        if (_mode == 1)
        {
            lstDir = mBuildDirInfo;
        }
        else if (_mode == 2)
        {
            lstDir = mModelDirInfo;
        }
        else if (_mode == 3)
        {
            lstDir = mConstructDirInfo;
        }

        if (selectedDirIndex < 0 || selectedDirIndex >= mModelDirInfo.Count)
            return null;

        DirectoryInfo dir = lstDir[selectedDirIndex];
        bool fileExist = File.Exists(dir.FullName + "/setting.bin");
        ExportSetting setting = new ExportSetting();
        if (fileExist)
        {
            FileStream fs = new FileStream(dir.FullName + "/setting.bin", FileMode.OpenOrCreate);
            BinaryReader br = new BinaryReader(fs, Encoding.Unicode);
            string param = br.ReadString();

            Dictionary<string, object> data = OurMiniJSON.Json.Deserialize(param) as Dictionary<string, object>;
            setting.exportName = (string)data["name"];
            setting.exportPath = (string)data["path"];

            setting.scale = new Vector3(float.Parse((string)data["sx"]), float.Parse((string)data["sy"]), float.Parse((string)data["sz"]));
            setting.layer = (string)data["layer"];
            setting.defaultClip = (string)data["clip"];
            setting.playAutomaically = (long)data["auto"] == 1;
            setting.cullType = (AnimationCullingType)((long)data["cull"]);
            setting.setting1 = new ExportSetting();

            if (data.ContainsKey("extra1"))
            {
                setting.extraExport1 = (long)data["extra1"] == 1;
                if (setting.extraExport1)
                {
                    setting.setting1.exportName = (string)data["name1"];
                    setting.setting1.exportPath = (string)data["path1"];

                    if (setting.setting1.exportName == setting.exportName && setting.setting1.exportPath == setting.exportPath)
                    {
                        setting.extraExport1 = false;
                        setting.setting1.exportName = null;
                        setting.setting1.exportPath = null;
                    }

                    setting.setting1.scale = new Vector3(float.Parse((string)data["sx1"]), float.Parse((string)data["sy1"]), float.Parse((string)data["sz1"]));
                    setting.setting1.layer = (string)data["layer1"];
                    setting.setting1.defaultClip = (string)data["clip1"];
                    setting.setting1.playAutomaically = (long)data["auto1"] == 1;
                    setting.setting1.cullType = (AnimationCullingType)((long)data["cull1"]);
                }
            }

            if (data.ContainsKey("sharename"))
            {
                setting.shareAnimModel = (string)data["sharename"];
            }
            if (data.ContainsKey("sharepath"))
            {
                setting.shareAnimPath = (string)data["sharepath"];
            }

            fs.Flush();
            fs.Close();
            br.Close();
        }
        else
        {
            string mainObjectName = string.Empty;
            FileInfo[] fileInfo = dir.GetFiles("*.FBX", SearchOption.TopDirectoryOnly);
            for (int i = 0; i < fileInfo.Length; i++)
            {
                if (fileInfo[i].Name.Contains("@"))
                {
                    mainObjectName = fileInfo[i].Name.Remove(fileInfo[i].Name.LastIndexOf("@"));
                    break;
                }
            }

            setting.exportName = "p_" + mainObjectName;
            setting.cullType = AnimationCullingType.BasedOnRenderers;
            setting.defaultClip = "idle";
            setting.scale = Vector3.one;
            setting.playAutomaically = false;
            setting.setting1 = new ExportSetting();

            // Default setting
            if (dir.FullName.Contains("unit"))
            {
                setting.exportPath = ResourceLibrary.ASSET_PATH_UNIT_MODEL;
                setting.layer = "units";
            }
            else if (dir.FullName.Contains("hero"))
            {
                setting.exportPath = ResourceLibrary.ASSET_PATH_HERO_MODEL;
                setting.layer = "units";
            }
        }
        return setting;
    }
}
