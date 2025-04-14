using UnityEngine;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using Excel;
#if UNITY_EDITOR_WIN && !UNITY_ANDROID && !UNITY_IPHONE
///using System.Data; 
#endif

// Parse Chapter Excel file and provide data
[CustomEditor(typeof(XLevelGenerator))]
public class XLevelGeneratorInspector : Editor 
{
	XLevelGenerator generator;

	string[] allChapterNames;
	string[] allChapterIds;
	string[] allLevelNames;
	string[] allLevelIds;
	int selectedChapter;
	int selectedLevel;

	string[] alllevelScenes;


    List<string> curChapterLevels = new List<string>();
    List<string> curChapterLevelScene = new List<string>();
    List<string> curChapterLevelId = new List<string>();
	void OnEnable()
	{
		generator = (XLevelGenerator)target;
#if UNITY_EDITOR_WIN && !UNITY_ANDROID && !UNITY_IPHONE
		string pathName = Application.dataPath + XLevelDefine.ExcelPath;
		ExcelReader.ReadXLSXInResource(pathName + XLevelDefine.ExcelFile_Chapter);
         // ExcelReader.dtDataSet.LogTable(XLevelDefine.ExcelSheet_Chapters);
		if (ExcelReader.success)
		{
            allChapterNames = ExcelReader.dtDataSet.GetColumnData(XLevelDefine.ExcelSheet_Chapters , "StringId" , 1);
            allChapterIds = ExcelReader.dtDataSet.GetColumnData(XLevelDefine.ExcelSheet_Chapters , "Id" , 1);
		}
#endif
		if (allChapterNames != null && allChapterNames.Length > 0)
		{
			selectedChapter = 0;
			for (int i=0; i<allChapterNames.Length; i++)
			{
				if (allChapterNames[i] == generator.chapterName)
				{
					selectedChapter = i;
					break;
				}
			}

            GetLevels(allChapterIds[selectedChapter]);
		}
        
	}

	public override void OnInspectorGUI() 
	{
		if (Application.isPlaying)
		{
			base.OnInspectorGUI();
			return;
		}

		EditorGUILayout.BeginVertical();

		if (allChapterNames != null && allChapterNames.Length > 0)
		{
			int selected = EditorGUILayout.Popup("Chapter:", selectedChapter, allChapterNames);
			if (selected != selectedChapter)
			{
				selectedChapter = selected;
                GetLevels(allChapterIds[selectedChapter]);
				selectedLevel = 0;
			}
		}

        if (curChapterLevels != null && curChapterLevels.Count > 0)
		{
			int selected = EditorGUILayout.Popup("Level:", selectedLevel, curChapterLevels.ToArray());
			if (selected != selectedLevel)
			{
				selectedLevel = selected;
			}

            EditorGUILayout.LabelField("Unity level file: " + curChapterLevelScene[selectedLevel]);
		}

        if (allChapterNames != null && allChapterNames.Length > 0 && curChapterLevels != null && curChapterLevels.Count > 0)
		{
			GUILayout.Space(10);
            if (GUILayout.Button("Generate level"))
            {
                generator.chapterId = allChapterIds[selectedChapter];
                generator.chapterName = allChapterNames[selectedChapter];
                XLevelDefine.Chapter_Path = allChapterNames[selectedChapter];

                generator.leveId = curChapterLevelId[selectedLevel];
                generator.levelName = curChapterLevels[selectedLevel];
                generator.levelSceneName = curChapterLevelScene[selectedLevel];
                XLevelDefine.Chapter_Scene = curChapterLevelScene[selectedLevel];

                generator.GenerateLevel(curChapterLevelScene[selectedLevel]);
            }
            GUILayout.Space(10);
            
            if(GUILayout.Button("Load Level for Xml"))
            {
                /*
                generator.chapterName = allChapterNames[selectedChapter];
                generator.chapterId = allChapterIds[selectedChapter];
                string xmlLevelData = alllevelScenes[selectedLevel];
                generator.levelSceneName = alllevelScenes[selectedLevel];
                 * */
                generator.chapterId = allChapterIds[selectedChapter];
                generator.chapterName = allChapterNames[selectedChapter];
                XLevelDefine.Chapter_Path = allChapterNames[selectedChapter];

                generator.leveId = curChapterLevelId[selectedLevel];
                generator.levelName = curChapterLevels[selectedLevel];
                generator.levelSceneName = curChapterLevelScene[selectedLevel];
                XLevelDefine.Chapter_Path = generator.chapterName;
                XLevelDefine.Chapter_Scene = generator.levelSceneName;

                XEditorManager.instance.LoadLevelFromXml(curChapterLevelScene[selectedLevel]);
            }
          
			GUILayout.Space(10);

			GUI.color = Color.green;
			if (GUILayout.Button("Save Level"))
			{
				    //XGroupInspector.Save();
			}
			GUI.color = Color.white;

			GUILayout.Space(40);

			if (GUILayout.Button("Refresh Excel Data"))
			{
				generator.chapterName = allChapterNames[selectedChapter];
				generator.chapterId = allChapterIds[selectedChapter];
                generator.ReloadExcel(alllevelScenes[selectedLevel]);
			}

			GUILayout.Space(40);
		}

		EditorGUILayout.EndVertical();
	}
    void GetLevels(string Chapterid)
    {
#if UNITY_EDITOR_WIN && !UNITY_ANDROID && !UNITY_IPHONE
        allLevelNames = ExcelReader.dtDataSet.GetColumnData(XLevelDefine.ExcelChapter_LevelSheet, "StringId" , 1);
        allLevelIds = ExcelReader.dtDataSet.GetColumnData(XLevelDefine.ExcelChapter_LevelSheet, "Id" , 1);
        alllevelScenes = ExcelReader.dtDataSet.GetColumnData(XLevelDefine.ExcelChapter_LevelSheet, "SceneData", 1);

        curChapterLevels.Clear();
        curChapterLevelScene.Clear();
        curChapterLevelId.Clear();
        string[] allLevelChapter = ExcelReader.dtDataSet.GetColumnData(XLevelDefine.ExcelChapter_LevelSheet, "ChapterId", 1);
        for(int i=0 ; i<allLevelChapter.Length; ++i)
        {
            if(allLevelChapter[i].Equals(Chapterid))
            {
                curChapterLevels.Add(allLevelNames[i]);
                curChapterLevelScene.Add(alllevelScenes[i]);
                curChapterLevelId.Add(allLevelIds[i]);
            }
        }
#endif
    }
}
