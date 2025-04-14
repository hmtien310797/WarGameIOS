using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using DigitalOpus.MB.Core;


public class CsMeshBakerHelperWindow : EditorWindow
{
    public GameObject SelectGameObject;
    public MB2_TextureBakeResults TexBakeResults;
    public bool supportLightmapping = true;
    public bool supportColors = false;

	public static CsMeshBakerHelperWindow Init () {
		CsMeshBakerHelperWindow window = (CsMeshBakerHelperWindow)EditorWindow.GetWindow (typeof (CsMeshBakerHelperWindow));
		window.Show();
        return window;
	}
	
	void OnGUI ()
    {
        EditorGUILayout.BeginVertical();
        EditorGUILayout.ObjectField("选择的合并根节点",SelectGameObject,typeof(GameObject),true);
        TexBakeResults = (MB2_TextureBakeResults)EditorGUILayout.ObjectField("选择纹理集合",TexBakeResults,typeof(MB2_TextureBakeResults),false);
        supportLightmapping = EditorGUILayout.Toggle("是否支持lightmapping",supportLightmapping);
        if(GUILayout.Button("BAKE"))
        {
            GameObject obj = new GameObject(SelectGameObject.name+"-mmb");
            MB3_MeshBaker mmb = obj.AddComponent<MB3_MeshBaker>();
            mmb.textureBakeResults = TexBakeResults;
            mmb.objsToMesh = new List<GameObject>();
            mmb.useObjsToMeshFromTexBaker = false;
            mmb.objsToMesh.AddRange(CsBatchingToolkit.GetMeshObjs(SelectGameObject));
            mmb.meshCombiner.doCol = supportColors;
            mmb.meshCombiner.lightmapOption = !supportLightmapping?MB2_LightmapOptions.ignore_UV2:MB2_LightmapOptions.generate_new_UV2_layout;
            MB3_MeshBakerEditorInternal.bake(mmb);
            GameObject.DestroyImmediate(obj);
        }
        EditorGUILayout.EndVertical();
	}
}

public class CsBatchingToolkit
{
    private static string MBTexAtlasPath = "Assets/Art/Models/LevelScene/Combine_MBT/Atlas/";
    private static string MBMeshPath = "Assets/Art/Models/LevelScene/Combine_MBT/Prefab/";


    public static GameObject[] GetMeshObjs(GameObject root)
    {
        MeshRenderer[] mrs = root.GetComponentsInChildren<MeshRenderer>();
        List<GameObject> objs = new List<GameObject>();
        for(int i =0,imax = mrs.Length;i<imax;i++)
        {
            if(mrs[i].enabled)
                objs.Add(mrs[i].gameObject);
        }
        return objs.ToArray();
    }

	private static void updateProgressBar(string msg, float progress)
    {
		EditorUtility.DisplayProgressBar("Combining Meshes", msg, progress);
	}

    private static void CreateMBTextureAtlas(GameObject root)
    {
        Clishow.CsFileHelper.CreateFolder(MBTexAtlasPath);
        string name = root.name;
        GameObject obj = new GameObject("tmp_mbTex");
        MB3_TextureBaker mmt = obj.AddComponent<MB3_TextureBaker>();
        SerializedObject textureBaker = new SerializedObject(mmt);
        SerializedProperty resultMaterials= textureBaker.FindProperty("resultMaterials");
        mmt.doMultiMaterial = true;
        mmt.maxAtlasSize = 1024;
        mmt.resizePowerOfTwoTextures = true;
        mmt.objsToMesh = new List<GameObject>();
        mmt.objsToMesh.AddRange(GetMeshObjs(root));
        MB3_TextureBakerEditorInternal.CreateCombinedMaterialAssets(mmt,MBTexAtlasPath+name+"-mbt-atlas.asset");
        MB3_TextureBakerEditorInternal.ConfigureMutiMaterialsFromObjsToCombine(mmt,resultMaterials,textureBaker);
	    mmt.CreateAtlases(updateProgressBar, true, new MB3_EditorMethods());
		EditorUtility.ClearProgressBar();
        if (mmt.textureBakeResults != null)
            EditorUtility.SetDirty(mmt.textureBakeResults);        
		textureBaker.ApplyModifiedProperties();		
		textureBaker.SetIsDifferentCacheDirty();
        GameObject.DestroyImmediate(obj);
    }

    [MenuItem("合并MESH/创建一个新的合并的材质集合...")]
    public static void SelectObjCreateMBTAtlas()
    {
        if (Selection.activeGameObject != null)
        {
            CreateMBTextureAtlas(Selection.activeGameObject);
        }
    }

    [MenuItem("合并MESH/合并网格...")]
    public static void SelectObjCombing()
    {
        if (Selection.activeGameObject != null)
        {
            CsMeshBakerHelperWindow wind = CsMeshBakerHelperWindow.Init();
            wind.SelectGameObject = Selection.activeGameObject;
        }
    }

    [MenuItem("合并MESH/SAVE...")]
    public static void SelectObjSave()
    {
        if (Selection.activeGameObject != null)
        {
            SaveMB3Object(Selection.activeGameObject);
        }
    }
    public static void SaveMB3Object(GameObject obj)
    {
        if (obj == null)
            return;
        {
            Clishow.CsFileHelper.CreateFolder(MBMeshPath);
            MeshFilter filter = obj.GetComponentInChildren<MeshFilter>();
            if (filter != null)
            {
                string p = MBMeshPath + obj.name + "-mbm.asset";
                SaveAsset(filter.sharedMesh, p);
                Mesh m = AssetDatabase.LoadAssetAtPath<Mesh>(p);
                filter.mesh = m;
                string per = MBMeshPath + obj.name + "-mbm.prefab";
                PrefabUtility.CreatePrefab(per, obj, ReplacePrefabOptions.ConnectToPrefab);
            }
        }
    }

    private static void SaveAsset(Mesh mesh, string path)
    {
        if (mesh == null)
            return;
        AssetDatabase.CreateAsset(mesh, path);
        AssetDatabase.SaveAssets();
    }
}
