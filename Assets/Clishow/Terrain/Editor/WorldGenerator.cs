using UnityEngine;
using UnityEditor;
using System.IO;
using System.Diagnostics;
using System.Collections.Generic;
using System.Text.RegularExpressions;

public class WorldGenerator : EditorWindow
{
    #region Variables

    private string map;

    private World3D world;
    private WorldBlockInfo worldBlockInfo;

    private string exportPath;
    private string export_ex_name;
    private byte initialObjectId;
    private int tileSize;
    private int gridWeight;

    private MeshRenderer worldRenderer;
    private bool enableBiome = true;
    private bool enableTerrain = true;
    private bool enableWall = false;
    private bool enableStructure = false;
    private int minX;
    private int minY;
    private int maxX;
    private int maxY;
    public Color[] colors;

    private int width;
    private int height;

    private char[] biomeInfoArray;
    private char[] terrainInfoArray;
    private char[] structureInfoArray;
    private char[] wallinfoArray;

    private Dictionary<string, List<IntVector2>> biomeInfoDict;
    private Dictionary<string, List<IntVector2>> terrainInfoDict;
    private Dictionary<string, List<IntVector2>> wallInfoDict;
    private Dictionary<string, List<IntVector2>> structureInfoDict;

    private SerializedObject serializedSelf;
    private byte OBJECT_ID;

    #endregion Variables
    #region Constants

    private static readonly Color color_desert = Color.Lerp(Color.yellow, Color.black, 0.3f);
    private static readonly Color color_mountain = Color.Lerp(Color.green, Color.black, 0.7f);
    
    #endregion Constants
    #region UnityEditor

    [MenuItem("Tools/World3D 生成")]
    public static WorldGenerator Init()
    {
        WorldGenerator window = (WorldGenerator)EditorWindow.GetWindow(typeof(WorldGenerator));
        window.Reset();
        window.Show();
        return window;
    }

    private void OnEnable()
    {
        serializedSelf = new SerializedObject(this);
    }

    private void OnGUI()
    {
        EditorGUILayout.BeginVertical();

        map = EditorGUILayout.TextField("地图文件位置（.lua）", map);
        if (GUILayout.Button("读取地图数据文件"))
            ReadDataFromFile();

        EditorGUILayout.Space();
        initialObjectId = (byte)EditorGUILayout.IntField("地图数据起始ID", initialObjectId);
        tileSize = EditorGUILayout.IntField("地图区块大小", tileSize);
        gridWeight = EditorGUILayout.IntField("网格线粗细", gridWeight);
        if (GUILayout.Button("导出地形构造简图（.png）"))
            ExportConfigurations();
        if (GUILayout.Button("生成World3D、WorldBlockInfo"))
            BuildWorld();

        EditorGUILayout.Space();
        exportPath = EditorGUILayout.TextField("导出至", exportPath);
        export_ex_name = EditorGUILayout.TextField("导出扩展名", export_ex_name);
        if (GUILayout.Button("导出World3D、WorldBlockInfo（.asset）"))
            ExportWorld();

        EditorGUILayout.Space();
        world = (World3D)EditorGUILayout.ObjectField("世界文件", world, typeof(World3D), true);
        EditorGUILayout.LabelField(string.Format("\t\t\t   {0} × {1}", world ? world.width.ToString() : "?", world ? world.height.ToString() : "?"), EditorStyles.miniLabel);
        worldBlockInfo = (WorldBlockInfo)EditorGUILayout.ObjectField("世界阻挡文件", worldBlockInfo, typeof(WorldBlockInfo), true);
        EditorGUILayout.LabelField(string.Format("\t\t\t   {0} × {1}", worldBlockInfo ? worldBlockInfo.width.ToString() : "?", worldBlockInfo ? worldBlockInfo.height.ToString() : "?"), EditorStyles.miniLabel);

        EditorGUILayout.Space();
        worldRenderer = (MeshRenderer)EditorGUILayout.ObjectField("渲染至", worldRenderer, typeof(Renderer), true);
        enableBiome = EditorGUILayout.ToggleLeft("地貌", enableBiome);
        enableTerrain = EditorGUILayout.ToggleLeft("地形", enableTerrain);
       //enableWall = EditorGUILayout.ToggleLeft("Wall", enableWall);
        //enableStructure = EditorGUILayout.ToggleLeft("生成地面物体 / 建筑", enableStructure);
        minX = EditorGUILayout.IntField("预览区域X轴最小值", minX);
        minY = EditorGUILayout.IntField("预览区域Y轴最小值", minY);
        maxX = EditorGUILayout.IntField("预览区域X轴最大值", maxX);
        maxY = EditorGUILayout.IntField("预览区域Y轴最大值", maxY);
        EditorGUI.BeginChangeCheck();
        EditorGUILayout.PropertyField(serializedSelf.FindProperty("colors"), new GUIContent("地形地貌颜色"), true);
        if (EditorGUI.EndChangeCheck())
            serializedSelf.ApplyModifiedProperties();
        if (GUILayout.Button("生成世界区域预览"))
            GenerateWorldPreviewFrowClientData();

        EditorGUILayout.Space();
        EditorGUILayout.LabelField(" ---------------------------------------------", EditorStyles.label);
        EditorGUILayout.LabelField("| 比较结果\t\t客户端\t服务器 |", EditorStyles.label);
        EditorGUILayout.LabelField("| 绿色\t\t有阻挡\t有阻挡 |", EditorStyles.label);
        EditorGUILayout.LabelField("| 黄色\t\t无阻挡\t有阻挡 |", EditorStyles.label);
        EditorGUILayout.LabelField("| 红色\t\t有阻挡\t无阻挡 |", EditorStyles.label);
        EditorGUILayout.LabelField(" ---------------------------------------------", EditorStyles.label);
        if (GUILayout.Button("比较阻挡信息"))
            DiffBlockInfo();

        EditorGUILayout.Space();
        EditorGUILayout.Space();
        if (GUILayout.Button("恢复预设"))
            Reset();

        EditorGUILayout.EndVertical();
    }

    #endregion UnityEditor
    #region Major Functionalities

    private void ReadDataFromFile()
    {
        if (map == null)
            return;

        Stopwatch stopwatch = new Stopwatch();
        stopwatch.Start();

        string path = map;

        if (enableBiome)
        {
            string[] buffer = File.ReadAllLines(string.Format("{0}_biome.txt", path.Substring(0, path.LastIndexOf('.'))));
            width = int.Parse(buffer[0]);
            height = int.Parse(buffer[1]);
            biomeInfoArray = new char[width * height];
            for (int x = 0; x < height; x++)
            {
                char[] array = buffer[x + 2].ToCharArray();
                for (int z = 0; z < width; z++)
                    biomeInfoArray[x * width + z] = array[z];
            }
        }

        if (enableTerrain)
        {
            string[] buffer = File.ReadAllLines(string.Format("{0}_terrain.txt", path.Substring(0, path.LastIndexOf('.'))));
            terrainInfoArray = new char[width * height];
            for (int x = 0; x < height; x++)
            {
                char[] array = buffer[x + 2].ToCharArray();
                for (int z = 0; z < width; z++)
                    terrainInfoArray[x * width + z] = array[z];
            }
        }

        if (enableWall)
        {
            string[] buffer = File.ReadAllLines(string.Format("{0}_wall.txt", path.Substring(0, path.LastIndexOf('.'))));
            wallinfoArray = new char[width * height];
            for (int x = 0; x < height; x++)
            {
                char[] array = buffer[x + 2].ToCharArray();
                for (int z = 0; z < width; z++)
                    wallinfoArray[x * width + z] = array[z];
            }
        }

        if (enableStructure)
        {
            string[] buffer = File.ReadAllLines(string.Format("{0}_object.txt", path.Substring(0, path.LastIndexOf('.'))));
            structureInfoArray = new char[width * height];
            for (int x = 0; x < height; x++)
            {
                char[] array = buffer[x + 2].ToCharArray();
                for (int z = 0; z < width; z++)
                    structureInfoArray[x * width + z] = array[z];
            }
        }

        stopwatch.Stop();
        UnityEngine.Debug.Log(string.Format("读取数据文件   {0}", stopwatch.Elapsed));
    }

    private void BuildWorld()
    {
        ReadDataFromFile();

        if (biomeInfoDict == null)
            LoadBiomeInfo();

        if (terrainInfoDict == null)
            LoadTerrainInfo();

        if (wallInfoDict == null)
            LoadWallInfo();

        if (structureInfoDict == null)
            LoadStructureInfo();

        Stopwatch stopwatch = new Stopwatch();
        stopwatch.Start();

        InitializeObjectID();

        List<WorldObject> worldObjects = new List<WorldObject>();
        int maxObjectWidth = 0;
        int maxObjectHeight = 0;

        byte[] biomeBlockData = new byte[width * height];
        if (enableBiome)
        {
            foreach (KeyValuePair<string, List<IntVector2>> pair in biomeInfoDict)
            {
                char[] config = pair.Key.ToCharArray();

                int minX = 0, maxX = 0;
                for (int i = 1; i < config.Length; i += 2)
                {
                    if (config[i] - 48 < minX)
                        minX = config[i] - 48;
                    else if (config[i] - 48 > maxX)
                        maxX = config[i] - 48;
                }

                int minY = 0, maxY = 0;
                for (int i = 2; i < config.Length; i += 2)
                {
                    if (config[i] - 48 < minY)
                        minY = config[i] - 48;
                    else if (config[i] - 48 > maxY)
                        maxY = config[i] - 48;
                }

                int objectWidth = 1 + maxX - minX;
                int objectHeight = 1 + maxY - minY;

                bool[,] coverage = new bool[objectWidth, objectHeight];

                for (int i = 1; i < config.Length; i += 2)
                {
                    int xi = config[i] - 48 - minX;
                    int yi = config[i + 1] - 48 - minY;

                    coverage[xi, yi] = true;
                }

                foreach (IntVector2 anchor in pair.Value)
                {
                    int x0 = anchor.x + minX;
                    int y0 = anchor.y + minY;

                    WorldObject obj = new WorldObject(OBJECT_ID, objectWidth, objectHeight, (short)((height - y0 - objectHeight / 2f) * tileSize), (short)((width - x0 - objectWidth / 2f) * tileSize));
                    worldObjects.Add(obj);

                    for (int xi = 0; xi < objectWidth; xi++)
                        for (int yi = 0; yi < objectHeight; yi++)
                            if (coverage[xi, yi])
                                biomeBlockData[(y0 + yi) * width + x0 + xi] = OBJECT_ID;
                }

                if (objectWidth > maxObjectWidth)
                    maxObjectWidth = objectWidth;

                if (objectHeight > maxObjectHeight)
                    maxObjectHeight = objectHeight;

                OBJECT_ID++;
            }
        }

        byte[] terrainBlockData = new byte[width * height];
        if (enableTerrain)
        {
            foreach (KeyValuePair<string, List<IntVector2>> pair in terrainInfoDict)
            {
                char[] config = pair.Key.ToCharArray();

                int minX = 0, maxX = 0;
                for (int i = 1; i < config.Length; i += 2)
                {
                    if (config[i] - 48 < minX)
                        minX = config[i] - 48;
                    else if (config[i] - 48 > maxX)
                        maxX = config[i] - 48;
                }

                int minY = 0, maxY = 0;
                for (int i = 2; i < config.Length; i += 2)
                {
                    if (config[i] - 48 < minY)
                        minY = config[i] - 48;
                    else if (config[i] - 48 > maxY)
                        maxY = config[i] - 48;
                }

                int objectWidth = 1 + maxX - minX;
                int objectHeight = 1 + maxY - minY;

                bool[,] coverage = new bool[objectWidth, objectHeight];

                for (int i = 1; i < config.Length; i += 2)
                {
                    int xi = config[i] - 48 - minX;
                    int yi = config[i + 1] - 48 - minY;

                    coverage[xi, yi] = true;
                }

                foreach (IntVector2 anchor in pair.Value)
                {
                    int x0 = anchor.x + minX;
                    int y0 = anchor.y + minY;
                    WorldObject obj = new WorldObject(OBJECT_ID, objectWidth, objectHeight, (short)((height - y0 - objectHeight / 2f) * tileSize), (short)((width - x0 - objectWidth / 2f) * tileSize));
                    worldObjects.Add(obj);

                    for (int xi = 0; xi < objectWidth; xi++)
                        for (int yi = 0; yi < objectHeight; yi++)
                            if (coverage[xi, yi])
                                terrainBlockData[(y0 + yi) * width + x0 + xi] = OBJECT_ID;
                }

                if (objectWidth > maxObjectWidth)
                    maxObjectWidth = objectWidth;

                if (objectHeight > maxObjectHeight)
                    maxObjectHeight = objectHeight;

                OBJECT_ID++;
            }
        }

        byte[] wallBlockData = new byte[width * height];
        if (enableWall)
        {
            foreach (KeyValuePair<string, List<IntVector2>> pair in wallInfoDict)
            {
                int objectWidth = 1;
                int objectHeight = 1;

                foreach (IntVector2 anchor in pair.Value)
                {
                    int x0 = anchor.x;
                    int y0 = anchor.y;
                    WorldObject obj = new WorldObject(OBJECT_ID, objectWidth, objectHeight, (short)((height - y0 - objectHeight / 2f) * tileSize), (short)((width - x0 - objectWidth / 2f) * tileSize));
                    worldObjects.Add(obj);
                    wallBlockData[(y0) * width + x0] = OBJECT_ID;
                }
                OBJECT_ID++;
            }
        }


            List<int> blockData = new List<int>();
        for (int y = 0; y < height; y++)
            for (int x = 0; x < width; x++)
                if (terrainBlockData[y * width + x] != 0 || biomeBlockData[y * width + x] != 0)
                    blockData.Add(x + (y << 9) + (terrainBlockData[y * width + x] << 18) + (biomeBlockData[y * width + x] << 25));

        world = ScriptableObject.CreateInstance<World3D>();
        world.Build(width, worldObjects.ToArray(), maxObjectWidth * tileSize, maxObjectHeight * tileSize, tileSize);

        worldBlockInfo = ScriptableObject.CreateInstance<WorldBlockInfo>();
        worldBlockInfo.Build(width, blockData.ToArray());

        stopwatch.Stop();
        UnityEngine.Debug.Log(string.Format("生成World3D、WorldBlockInfo   {0}", stopwatch.Elapsed));
    }

    private void ExportConfigurations()
    {
        ReadDataFromFile();

        InitializeObjectID();

        if (biomeInfoDict == null)
            LoadBiomeInfo();

        if (terrainInfoDict == null)
            LoadTerrainInfo();

        if (wallInfoDict == null)
            LoadWallInfo();

        if (structureInfoDict == null)
            LoadStructureInfo();

        BuildWorld();
        InitializeObjectID();

        if (enableBiome)
            foreach (KeyValuePair<string, List<IntVector2>> pair in biomeInfoDict)
                ExportConfiguration(pair.Key.ToCharArray());

        if (enableTerrain)
            foreach (KeyValuePair<string, List<IntVector2>> pair in terrainInfoDict)
                ExportConfiguration(pair.Key.ToCharArray());

        if (enableWall)
            foreach (KeyValuePair<string, List<IntVector2>> pair in wallInfoDict)
                ExportConfiguration(pair.Key.ToCharArray());

        if (enableStructure)
            foreach (KeyValuePair<string, List<IntVector2>> pair in structureInfoDict)
                ExportConfiguration(pair.Key.ToCharArray());
    }

    private void ExportWorld()
    {
        if (world == null || worldBlockInfo == null)
            BuildWorld();

        AssetDatabase.CreateAsset(world, exportPath + "World3D"+ export_ex_name + ".asset");
        AssetDatabase.CreateAsset(worldBlockInfo, exportPath + "WorldBlockInfo"+ export_ex_name + ".asset");
    }

    private void GenerateWorldPreviewFrowClientData()
    {
        if (worldBlockInfo == null)
            BuildWorld();

        width = worldBlockInfo.width;
        height = worldBlockInfo.height;

        float numTiles = width * height;

        Texture2D texture = new Texture2D(width, height);
        Color[] colors = new Color[(int)numTiles];

        if (enableBiome)
        {
            for (int y = 0; y < height; y++)
                for (int x = 0; x < width; x++)
                    if ((worldBlockInfo[x, y] & 0x7f) != 0)
                    {
                        int i = y * width + x;
                        colors[i] = GetColorByID(worldBlockInfo[x, y] & 0x7f);

                        #if UNITY_EDITOR
                        float progress = i / numTiles;
                        UnityEditor.EditorUtility.DisplayProgressBar("生成地貌预览...", string.Format("{0:P}", progress), progress);
                        #endif
                    }
        }

        if (enableTerrain)
        {
            for (int y = 0; y < height; y++)
                for (int x = 0; x < width; x++)
                    if (((worldBlockInfo[x, y] >> 7) & 0x7f) != 0)
                    {
                        int i = y * width + x;
                        colors[i] = GetColorByID((worldBlockInfo[x, y] >> 7) & 0x7f);

                        #if UNITY_EDITOR
                        float progress = i / numTiles;
                        UnityEditor.EditorUtility.DisplayProgressBar("生成地形预览...", string.Format("{0:P}", progress), progress);
                        #endif
                    }
        }

        #if UNITY_EDITOR
        UnityEditor.EditorUtility.ClearProgressBar();
        #endif

        texture.SetPixels(colors);
        texture.Apply();

        if (!worldRenderer)
            worldRenderer = GameObject.CreatePrimitive(PrimitiveType.Plane).GetComponent<MeshRenderer>();

        worldRenderer.transform.name = "World Preview @ " + System.DateTime.Now.ToLongTimeString();
        worldRenderer.transform.position = Vector3.zero;
        worldRenderer.transform.localRotation = Quaternion.Euler(45, 90, -90);
        worldRenderer.transform.localScale = new Vector3(width, 1, height);

        worldRenderer.sharedMaterial.mainTexture = texture;
    }

    private void GenerateWorldPreviewFromServerData()
    {
        string buffer = File.ReadAllText(string.Format("{0}_blockInfo.txt", map.Substring(0, map.LastIndexOf('.'))));

        bool[,] data = new bool[width, height];

        string[] coordinates = buffer.Split('}');

        for (int i = 0; i < coordinates.Length; i++)
        {
            Regex r = new Regex("\\d+(\\.\\d+)?");
            MatchCollection matches = r.Matches(coordinates[i]);
            if (matches.Count == 2)
            {
                int x = int.Parse(matches[0].Groups[0].Value);
                int y = int.Parse(matches[1].Groups[0].Value);

                data[x, y] = true;
            }
        }

        Texture2D texture = new Texture2D(width, height);
        Color[] colors = new Color[width * height];

        for (int y = 0; y < height; y++)
            for (int x = 0; x < width; x++)
            {
                if (data[x, y])
                {
                    int i = y * width + x;
                    colors[i] = Color.red;

#if UNITY_EDITOR
                    float progress = i / (float)(width * height);
                    UnityEditor.EditorUtility.DisplayProgressBar("Generating World Block Infomation...", string.Format("{0:P}", progress), progress);
#endif
                }
            }

#if UNITY_EDITOR
        UnityEditor.EditorUtility.ClearProgressBar();
#endif

        texture.SetPixels(colors);
        texture.Apply();

        if (!worldRenderer)
            worldRenderer = GameObject.CreatePrimitive(PrimitiveType.Plane).GetComponent<MeshRenderer>();

        worldRenderer.transform.name = "World Preview @ " + System.DateTime.Now.ToLongTimeString();
        worldRenderer.transform.position = Vector3.zero;
        worldRenderer.transform.localRotation = Quaternion.Euler(45, 90, -90);
        worldRenderer.transform.localScale = new Vector3(width, 1, height);

        worldRenderer.sharedMaterial.mainTexture = texture;
    }

    private void DiffBlockInfo()
    {
        if (worldBlockInfo == null)
            BuildWorld();

        width = worldBlockInfo.width;
        height = worldBlockInfo.height;

        string buffer = File.ReadAllText(string.Format("{0}_serverBlockInfo.txt", map.Substring(0, map.LastIndexOf('.'))));

        bool[,] serverBlockInfo = new bool[width, height];

        string[] coordinates = buffer.Split('}');

        for (int i = 0; i < coordinates.Length; i++)
        {
            Regex r = new Regex("\\d+(\\.\\d+)?");
            MatchCollection matches = r.Matches(coordinates[i]);
            if (matches.Count == 2)
            {
                int x = int.Parse(matches[0].Groups[0].Value);
                int y = int.Parse(matches[1].Groups[0].Value);

                serverBlockInfo[x, y] = true;
            }
        }

        Color[] colors = new Color[width * height];

        #if UNITY_EDITOR
        float numTiles = width * height;
        #endif

        for (int y = 0; y < height; y++)
            for (int x = 0; x < width; x++)
            {
                Color color = Color.black;

                int clientBlockInfo = worldBlockInfo[x, y] & 0x7f;
                if (serverBlockInfo[x, y] && clientBlockInfo != 0)
                    color = Color.green; // 阻挡信息正确
                else if (serverBlockInfo[x, y] && clientBlockInfo == 0)
                    color = Color.yellow; // 客户端阻挡信息缺失
                else if (!serverBlockInfo[x, y] && clientBlockInfo != 0)
                    color = Color.red;  // 服务器阻挡信息缺失

                int i = y * width + x;
                colors[i] = color;

                #if UNITY_EDITOR
                float progress = i / numTiles;
                EditorUtility.DisplayProgressBar("比较阻挡信息...", string.Format("{0:P}", progress), progress);
                #endif
            }

        #if UNITY_EDITOR
        EditorUtility.ClearProgressBar();
        #endif

        Texture2D texture = new Texture2D(width, height);
        texture.SetPixels(colors);
        texture.Apply();

        MeshRenderer canvas = GameObject.CreatePrimitive(PrimitiveType.Plane).GetComponent<MeshRenderer>();
        canvas.transform.name = "Diff BlockInfo @ " + System.DateTime.Now.ToLongTimeString();
        canvas.transform.position = Vector3.zero;
        canvas.transform.localRotation = Quaternion.Euler(45, 90, -90);
        canvas.transform.localScale = new Vector3(width, 1, height);

        canvas.sharedMaterial.mainTexture = texture;
    }

    private void Reset()
    {
        map = "D:\\wgame\\trunk\\art\\Map\\world3d.lua";

        initialObjectId = 6;
        tileSize = 16;
        gridWeight = 4;

        exportPath = "Assets\\Clishow\\Terrain\\Resources\\";

        world = null;
        worldBlockInfo = null;
        width = height = 0;
        biomeInfoArray = terrainInfoArray  = wallinfoArray = structureInfoArray = null;
        terrainInfoDict = wallInfoDict = biomeInfoDict = structureInfoDict = null;

        if (worldRenderer != null)
            worldRenderer.transform.localScale = new Vector3(0, 0, 0);
        enableBiome = true;
        enableTerrain = true;
        enableStructure = false;
        minX = 0;
        minY = 0;
        maxX = 511;
        maxY = 511;
        colors = new Color[16];
        colors[6] = color_desert;
        colors[7] = color_desert;
        colors[8] = color_desert;
        colors[9] = color_desert;
        colors[10] = color_desert;
        colors[11] = Color.gray;
        colors[12] = color_mountain;
        colors[13] = color_mountain;
        colors[14] = Color.blue;
        colors[15] = color_mountain;

        serializedSelf = new SerializedObject(this);
    }

    #endregion Major Functionalities
    #region Helper Functions

    private void LoadBiomeInfo()
    {
        if (!enableBiome)
            return;

        Stopwatch stopwatch = new Stopwatch();
        stopwatch.Start();

        float numTiles = width * height;

        biomeInfoDict = new Dictionary<string, List<IntVector2>>();

        bool[,] visited = new bool[width, height];
        for (int y = 0; y < height; y++)
            for (int x = 0; x < width; x++)
                if (!visited[x, y])
                {
                    char type = biomeInfoArray[y * width + x];

                    if (type != ' ')
                    {
                        string config = "";
                        config += type;

                        IntVector2 anchor = new IntVector2(x, y);

                        Stack<IntVector2> s = new Stack<IntVector2>();
                        s.Push(new IntVector2(x, y));

                        int xi, yi;
                        while (s.Count != 0)
                        {
                            xi = s.Peek().x;
                            yi = s.Pop().y;

                            if (visited[xi, yi])
                                continue;

                            config += (char)(48 + xi - x);
                            config += (char)(48 + yi - y);

                            visited[xi, yi] = true;

                            if (GetTypeFromBiomeInfoArray(xi, yi + 1) == type)
                                s.Push(new IntVector2(xi, yi + 1));
                            if (GetTypeFromBiomeInfoArray(xi, yi - 1) == type)
                                s.Push(new IntVector2(xi, yi - 1));
                            if (GetTypeFromBiomeInfoArray(xi + 1, yi) == type)
                                s.Push(new IntVector2(xi + 1, yi));
                            if (GetTypeFromBiomeInfoArray(xi - 1, yi) == type)
                                s.Push(new IntVector2(xi - 1, yi));
                        }

                        if (!biomeInfoDict.ContainsKey(config))
                            biomeInfoDict.Add(config, new List<IntVector2>());

                        biomeInfoDict[config].Add(anchor);
#if UNITY_EDITOR
                        float progress = (y * width + x + 1) / numTiles;
                        EditorUtility.DisplayProgressBar("读取地貌信息...", string.Format("{0:P}", progress), progress);
#endif
                    }
                }
#if UNITY_EDITOR
        UnityEditor.EditorUtility.ClearProgressBar();
#endif

        stopwatch.Stop();
        UnityEngine.Debug.Log(string.Format("读取地貌信息   {0}", stopwatch.Elapsed));
    }

    private void LoadTerrainInfo()
    {
        if (!enableTerrain)
            return;

        Stopwatch stopwatch = new Stopwatch();
        stopwatch.Start();

        float numTiles = width * height;

        terrainInfoDict = new Dictionary<string, List<IntVector2>>();

        Stack<IntVector2> s = new Stack<IntVector2>();
        bool[,] visited = new bool[height, width];
        for (int y = 0; y < height; y++)
            for (int x = 0; x < width; x++)
                if (!visited[y, x])
                {
                    char type = terrainInfoArray[y * width + x];
                    if (type != ' ')
                    {
                        string config = type.ToString();

                        IntVector2 anchor = new IntVector2(x, y);
                        s.Push(anchor);

                        int xi, yi;
                        while (s.Count != 0)
                        {
                            xi = s.Peek().x;
                            yi = s.Pop().y;

                            config += (char)(48 + xi - x);
                            config += (char)(48 + yi - y);
                            
                            if (!visited[yi + 1, xi])
                            {
                                char _type = GetTypeFromTerrainInfoArray(xi, yi + 1);
                                if (_type == type)
                                {
                                    s.Push(new IntVector2(xi, yi + 1));
                                    visited[yi + 1, xi] = true;
                                }
                                else if (_type == ' ')
                                    visited[yi + 1, xi] = true;
                            }

                            if (!visited[yi - 1, xi])
                            {
                                char _type = GetTypeFromTerrainInfoArray(xi, yi - 1);
                                if (_type == type)
                                {
                                    s.Push(new IntVector2(xi, yi - 1));
                                    visited[yi - 1, xi] = true;
                                }
                                else if (_type == ' ')
                                    visited[yi - 1, xi] = true;
                            }

                            if (!visited[yi, xi + 1])
                            {
                                char _type = GetTypeFromTerrainInfoArray(xi + 1, yi);
                                if (_type == type)
                                {
                                    s.Push(new IntVector2(xi + 1, yi));
                                    visited[yi, xi + 1] = true;
                                }
                                else if (_type == ' ')
                                    visited[yi, xi + 1] = true;

                            }

                            if (!visited[yi, xi - 1])
                            {
                                char _type = GetTypeFromTerrainInfoArray(xi - 1, yi);
                                if (_type == type)
                                {
                                    s.Push(new IntVector2(xi - 1, yi));
                                    visited[yi, xi - 1] = true;
                                }
                                else if (_type == ' ')
                                    visited[yi, xi - 1] = true;
                            }
                        }

                        if (!terrainInfoDict.ContainsKey(config))
                            terrainInfoDict.Add(config, new List<IntVector2>());

                        terrainInfoDict[config].Add(anchor);
                    }
                    else
                        visited[y, x] = true;

                    #if UNITY_EDITOR
                    float progress = (y * width + x) / numTiles;
                    EditorUtility.DisplayProgressBar("读取地形信息...", string.Format("{0:P}", progress), progress);
                    #endif
                }

        #if UNITY_EDITOR
        UnityEditor.EditorUtility.ClearProgressBar();
        #endif

        stopwatch.Stop();
        UnityEngine.Debug.Log(string.Format("读取地形信息   {0}", stopwatch.Elapsed));
    }

    private void LoadWallInfo()
    {
        if (!enableWall)
            return;

        Stopwatch stopwatch = new Stopwatch();
        stopwatch.Start();

        float numTiles = width * height;

        wallInfoDict = new Dictionary<string, List<IntVector2>>();
       
        bool[,] visited = new bool[height, width];
        for (int y = 0; y < height; y++)
            for (int x = 0; x < width; x++)
                if (!visited[y, x])
                {
                    char type = wallinfoArray[y * width + x];
                    if (type != ' ')
                    {
                        string config = type.ToString();

                        IntVector2 anchor = new IntVector2(x, y);
                        if (!wallInfoDict.ContainsKey(config))
                            wallInfoDict.Add(config, new List<IntVector2>());

                        wallInfoDict[config].Add(anchor);
                    }
                    else
                        visited[y, x] = true;

#if UNITY_EDITOR
                    float progress = (y * width + x) / numTiles;
                    EditorUtility.DisplayProgressBar("读取地形信息...", string.Format("{0:P}", progress), progress);
#endif
                }

#if UNITY_EDITOR
        UnityEditor.EditorUtility.ClearProgressBar();
#endif

        stopwatch.Stop();
        UnityEngine.Debug.Log(string.Format("读取地形信息   {0}", stopwatch.Elapsed));
    }

    private void LoadStructureInfo()
    {
        if (!enableStructure)
            return;

        structureInfoDict = new Dictionary<string, List<IntVector2>>();

        bool[,] visited = new bool[width, height];
        for (int y = 0; y < height; y++)
            for (int x = 0; x < width; x++)
                if (!visited[x, y])
                {
                    char type = GetTypeFromStructureInfoArray(x, y);

                    if (type != ' ')
                    {
                        string config = "";
                        config += type;

                        IntVector2 anchor = new IntVector2(x, y);

                        Stack<IntVector2> s = new Stack<IntVector2>();
                        s.Push(anchor);

                        int xi, yi;
                        while (s.Count != 0)
                        {
                            xi = s.Peek().x;
                            yi = s.Pop().y;
                            config += (char)(48 + xi - x);
                            config += (char)(48 + yi - y);

                            visited[xi, yi] = true;

                            if (GetTypeFromStructureInfoArray(xi + 1, yi) == type && !visited[xi + 1, yi])
                                s.Push(new IntVector2(xi + 1, yi));
                            if (GetTypeFromStructureInfoArray(xi, yi + 1) == type && !visited[xi, yi + 1])
                                s.Push(new IntVector2(xi, yi + 1));
                            if (GetTypeFromStructureInfoArray(xi - 1, yi) == type && !visited[xi - 1, yi])
                                s.Push(new IntVector2(xi - 1, yi));
                            if (GetTypeFromStructureInfoArray(xi, yi - 1) == type && !visited[xi, yi - 1])
                                s.Push(new IntVector2(xi, yi - 1));
                        }

                        if (!structureInfoDict.ContainsKey(config))
                            structureInfoDict.Add(config, new List<IntVector2>());

                        structureInfoDict[config].Add(new IntVector2(x, y));
                    }
                }
    }

    private void InitializeObjectID()
    {
        OBJECT_ID = initialObjectId;
    }

    private void ExportConfiguration(char[] configuration)
    {
        int minX = 0, maxX = 0;
        for (int i = 1; i < configuration.Length; i += 2)
        {
            if (configuration[i] - 48 < minX)
                minX = configuration[i] - 48;
            else if (configuration[i] - 48 > maxX)
                maxX = configuration[i] - 48;
        }

        int minY = 0, maxY = 0;
        for (int i = 2; i < configuration.Length; i += 2)
        {
            if (configuration[i] - 48 < minY)
                minY = configuration[i] - 48;
            else if (configuration[i] - 48 > maxY)
                maxY = configuration[i] - 48;
        }

        int imageWidth = (maxX - minX + 1 + 2) * tileSize;
        int imageHeight = (maxY - minY + 1 + 2) * tileSize;

        Color[] colors = new Color[imageWidth * imageHeight];

        for (int n = 0; n < gridWeight / 2; n++)
        {
            for (int y = 0; y < imageHeight; y++)
                for (int x = 0; x < imageWidth; x += tileSize)
                {
                    colors[y * imageWidth + x + n] = Color.black;
                    colors[y * imageWidth + x + tileSize - 1 - n] = Color.black;
                }

            for (int y = 0; y < imageHeight; y += tileSize)
                for (int x = 0; x < imageWidth; x++)
                {
                    colors[(y + n) * imageWidth + x] = Color.black;
                    colors[(y + tileSize - 1 - n) * imageWidth + x] = Color.black;
                }
        }

        for (int i = 1; i < configuration.Length; i += 2)
        {
            int x = configuration[i] - 48 - minX + 1;
            int y = configuration[i + 1] - 48 - minY + 1;

            Color color = GetColorByType(configuration[0]);

            if (configuration[i] == '0' && configuration[i + 1] == '0')
                color = Color.red;

            for (int dx = 0; dx < tileSize - gridWeight; dx++)
                for (int dy = 0; dy < tileSize - gridWeight; dy++)
                    colors[(imageHeight - 1 - y * tileSize - gridWeight / 2 - dy) * imageWidth + x * tileSize + gridWeight / 2 + dx] = color;
        }

        int xc = (imageWidth - 1) / 2;
        int yc = (imageHeight - 1) / 2;
        for (int yi = 0; yi < 3; yi++)
            for (int xi = 0; xi < 3; xi++)
            {
                colors[(yc - yi) * imageWidth + xc - xi] = Color.red;
                colors[(yc - yi) * imageWidth + xc + 1 + xi] = Color.red;
                colors[(yc + 1 + yi) * imageWidth + xc - xi] = Color.red;
                colors[(yc + 1 + yi) * imageWidth + xc + 1 + xi] = Color.red;
            }

        Texture2D image = new Texture2D(imageWidth, imageHeight, TextureFormat.ARGB32, false);
        image.SetPixels(colors);

        string directory = string.Format("{0}_config", map.Substring(0, map.IndexOf('.')));
        if (!Directory.Exists(directory))
            Directory.CreateDirectory(directory);

        FileStream file = File.Open(directory + string.Format("/{0:D}_{1}.png", OBJECT_ID++, GetTypeString(configuration[0])), FileMode.Create);
        BinaryWriter writer = new BinaryWriter(file);
        writer.Write(image.EncodeToPNG());
        file.Close();
    }

    private string GetTypeString(char type)
    {
        switch (type)
        {
            case 'D':
                return "desert";
            case 'M':
                return "mountain";
            case 'L':
                return "lake";
            case 'G':
                return "central_area";
            case 'A':
                return "wall_a";
            case 'B':
                return "wall_b";
            case 'C':
                return "wall_c";
            case 'E':
                return "wall_e";
            case 'F':
                return "wall_f";
            case 'Z':
                return "wall_z";
            case 'H':
                return "wall_h";
            case 'I':
                return "wall_i";
            case 'J':
                return "wall_j";
            case 'K':
                return "wall_k";
            case 'N':
                return "wall_n";
            case 'O':
                return "wall_o";
            default:
                return "unknown";
        }
    }

    private Color GetColorByType(char type)
    {
        switch (type)
        {
            case 'D':
                return color_desert;
            case 'M':
                return color_mountain;
            case 'L':
                return Color.blue;
            case 'G':
                return Color.gray;
            case 'A':
                return Color.green;
            case 'B':
                return Color.green;
            case 'C':
                return Color.green;
            case 'E':
                return Color.green;
            case 'F':
                return Color.green;
            case 'Z':
                return Color.green;
            case 'H':
                return Color.green;
            case 'I':
                return Color.green;
            case 'J':
                return Color.green;
            case 'K':
                return Color.green;
            case 'N':
                return Color.green;
            case 'O':
                return Color.green;
            default:
                return Color.red;
        }
    }

    private Color GetColorByID(int id)
    {
        if (id >= initialObjectId && id < colors.Length)
            return colors[id];

        return Color.red;

        //switch (id)
        //{
        //    case 6:
        //        return D;
        //    case 7:
        //        return D;
        //    case 8:
        //        return D;
        //    case 9:
        //        return D;
        //    case 10:
        //        return D;
        //    case 11:
        //        return Color.gray;
        //    case 12:
        //        return M;
        //    case 13:
        //        return M;
        //    case 14:
        //        return Color.blue;
        //    default:
        //        return Color.white;
        //}
    }

    private char GetTypeFromTerrainInfoArray(int x, int y)
    {
        if (x < 0 || y < 0 || x >= width || y >= height)
            return '*';

        return terrainInfoArray[y * width + x];
    }

    private char GetTypeFromWallInfoArray(int x, int y)
    {
        if (x < 0 || y < 0 || x >= width || y >= height)
            return '*';

        return  wallinfoArray[y * width + x];
    }

    private char GetTypeFromBiomeInfoArray(int x, int y)
    {
        if (x < 0 || y < 0 || x >= width || y >= height)
            return '*';

        return biomeInfoArray[y * width + x];
    }

    private char GetTypeFromStructureInfoArray(int x, int y)
    {
        if (x < 0 || y < 0 || x >= width || y >= height)
            return '*';

        return structureInfoArray[y * width + x];
    }

    #endregion Helper Functions
}
