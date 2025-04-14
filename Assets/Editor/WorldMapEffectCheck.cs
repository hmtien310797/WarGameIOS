using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
public class WorldMapEffectCheck : EditorWindow
{
    public class EffectInfo
    {
        public string Name;
        public int ParticleNum;
        public int TextureNum;
        public int MaxTextureSize;
        public int MeshNum;
        public int MaxMeshV;
        public List<string> MeshNames = new List<string>();
        public List<string> TexNames = new List<string>();
    }

    List<EffectInfo> effect_infos = new List<EffectInfo>();
    static WorldMapEffectCheck window;
    [MenuItem("Tools/Check World Map Effect...")]
    static void CreateWindow()
    {
        if (window != null)
        {
            window.Close();
        }
        else
        {
            window = (WorldMapEffectCheck)EditorWindow.GetWindow(typeof(WorldMapEffectCheck));
            window.titleContent.text = "World Map Effect";
            window.minSize = new Vector2(800, 600);
            window.Init();
            window.Show();
            window.ShowUtility();
        }
    }

    private void RecordMesh(EffectInfo info, Mesh mesh)
    {
        if (mesh != null)
        {
            if (!info.MeshNames.Contains(mesh.name))
            {
                info.MeshNames.Add(mesh.name);
                info.MeshNum++;
                if (mesh.vertexCount > info.MaxMeshV)
                {
                    info.MaxMeshV = mesh.vertexCount;
                }
            }

        }
    }

    private void RecordTexture(EffectInfo info, Material mat)
    {
        if (mat != null)
        {
            Texture tex = mat.GetTexture("_MainTex");
            if (tex != null)
            {
                if (!info.TexNames.Contains(tex.name))
                {
                    info.TextureNum++;
                    int max = Mathf.Max(tex.width, tex.height);
                    if (max > info.MaxTextureSize)
                        info.MaxTextureSize = max;
                }

            }
        }
    }

    private EffectInfo FillEffectInfo(GameObject obj)
    {
        EffectInfo info;
        List<ParticleSystem> pss = new List<ParticleSystem>();
        ParticleSystem ps;
        ParticleSystem[] psarray;
        info = new EffectInfo();
        info.Name = obj.name;
        pss.Clear();
        ps = obj.transform.GetComponent<ParticleSystem>();
        if (ps != null)
        {
            pss.Add(ps);
        }
        psarray = obj.transform.GetComponentsInChildren<ParticleSystem>();
        if (psarray != null)
        {
            pss.AddRange(psarray);
        }
        info.ParticleNum = pss.Count;
        for (int i = 0; i < pss.Count; i++)
        {
            ParticleSystemRenderer render = pss[i].GetComponent<Renderer>() as ParticleSystemRenderer;
            RecordMesh(info, render.mesh);
            RecordTexture(info, render.sharedMaterial);
        }

        MeshFilter mf = obj.transform.GetComponent<MeshFilter>();
        if (mf != null)
        {
            RecordMesh(info, mf.mesh);
        }

        MeshRenderer mr = obj.transform.GetComponent<MeshRenderer>();
        if (mr != null)
        {
            RecordTexture(info, mr.sharedMaterial);
        }

        MeshFilter[] mfs = obj.transform.GetComponentsInChildren<MeshFilter>();
        if (mfs != null)
        {
            for (int i = 0; i < mfs.Length; i++)
            {
                RecordMesh(info, mfs[i].mesh);
            }
        }

        MeshRenderer[] mrs = obj.transform.GetComponentsInChildren<MeshRenderer>();
        if (mrs != null)
        {
            for (int i = 0; i < mrs.Length; i++)
            {
                RecordTexture(info, mrs[i].sharedMaterial);
            }
        }

        SkinnedMeshRenderer smr = obj.transform.GetComponent<SkinnedMeshRenderer>();
        if (smr != null)
        {
            RecordMesh(info, smr.sharedMesh);
            RecordTexture(info, smr.sharedMaterial);
        }

        SkinnedMeshRenderer[] smrs = obj.transform.GetComponentsInChildren<SkinnedMeshRenderer>();
        if (smrs != null)
        {
            for (int i = 0; i < smrs.Length; i++)
            {
                RecordMesh(info, smrs[i].sharedMesh);
                RecordTexture(info, smrs[i].sharedMaterial);
            }
        }
        return info;
    }

    public void Init()
    {
        WorldMapMgr wmm = AssetDatabase.LoadAssetAtPath<WorldMapMgr>("Assets/Resources/WorldTerrain/3DTerrain.prefab");


        for (int i = 0; i < wmm.world.worldMapBuildEffect.Objects.Length; i++)
        {
            effect_infos.Add(FillEffectInfo(wmm.world.worldMapBuildEffect.Objects[i]));
        }
        for (int i = 0; i < wmm.world.worldMapEffect.Objects.Length; i++)
        {
            effect_infos.Add(FillEffectInfo(wmm.world.worldMapEffect.Objects[i]));
        }

    }

    Vector3 scorllPos;

    void OnGUI()
    {
        EditorGUILayout.BeginVertical();
        scorllPos = EditorGUILayout.BeginScrollView(scorllPos);
        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField("特效名稱");
        EditorGUILayout.LabelField("粒子系統數量");
        EditorGUILayout.LabelField("紋理數量");
        EditorGUILayout.LabelField("最大紋理size");
        EditorGUILayout.LabelField("Mesh數量");
        EditorGUILayout.LabelField("最大Mesh頂點數量");
        EditorGUILayout.EndHorizontal();
        for (int i = 0; i < effect_infos.Count; i++)
        {
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField(effect_infos[i].Name);
            EditorGUILayout.LabelField(effect_infos[i].ParticleNum.ToString());
            EditorGUILayout.LabelField(effect_infos[i].TextureNum.ToString());
            EditorGUILayout.LabelField(effect_infos[i].MaxTextureSize.ToString());
            EditorGUILayout.LabelField(effect_infos[i].MeshNum.ToString());
            EditorGUILayout.LabelField(effect_infos[i].MaxMeshV.ToString());
            EditorGUILayout.EndHorizontal();
        }
        EditorGUILayout.EndScrollView();
        EditorGUILayout.EndVertical();
    }

}
