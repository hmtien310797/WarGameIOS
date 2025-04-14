using UnityEngine;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using Clishow;
[CustomEditor(typeof(XElementEditor))]
public class XElementInspector : Editor {

	XElementEditor editor;

    //unit
    string[] nameOfUnits;
    int[] idsOfUnits;
	//defense
    string[] nameOfDefenses;
    int[] idsOfDefenses;
    

	GUIStyle style = new GUIStyle();

	void OnEnable()
	{
		if (Application.isPlaying)
		{
			return;
		}

		editor = (XElementEditor)target;
		style.fontStyle = FontStyle.Bold;
		style.normal.textColor = Color.blue;

        //monstert
        string levelId = string.Empty;
        XLevelGenerator lvgenerator = GameObject.FindObjectOfType<XLevelGenerator>();



        //unit
        List<Serclimax.Unit.ScUnitData> listUnit = new List<Serclimax.Unit.ScUnitData>();
        foreach (Serclimax.Unit.ScUnitData suData in XEditorManager.eScTableData.GetTable<Serclimax.Unit.ScUnitData>().Data.Values)
        {
            if (suData._unitBattleId == int.Parse(lvgenerator.leveId) || suData._unitBattleId == 0)
            {
                listUnit.Add(suData);
            }
        }
        nameOfUnits = new string[listUnit.Count];
        idsOfUnits = new int[listUnit.Count];
        int j = 0;
        foreach (Serclimax.Unit.ScUnitData uinfo in listUnit)
        {
            nameOfUnits[j] = uinfo._unitName;
            idsOfUnits[j] = uinfo._unitTableId;
            j++;
        }

        //defenses
        List<Serclimax.Unit.ScUnitDefenseData> listDefense = new List<Serclimax.Unit.ScUnitDefenseData>();
        foreach (Serclimax.Unit.ScUnitDefenseData suData in XEditorManager.eScTableData.GetTable<Serclimax.Unit.ScUnitDefenseData>().Data.Values)
        {
            if(suData._unitDefenseBattleId == int.Parse(lvgenerator.leveId)||suData._unitDefenseBattleId==999)
            {
                listDefense.Add(suData);
            }
        }
        nameOfDefenses = new string[listDefense.Count];
        idsOfDefenses = new int[listDefense.Count];
        j = 0;
        foreach (Serclimax.Unit.ScUnitDefenseData coninfo in listDefense)
        {
            nameOfDefenses[j] = coninfo._unitCfgName;
            idsOfDefenses[j] = coninfo._unitDefenseTableId;
            j++;
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

		GUI.color = new Color32(118,228,244,255);

		EditorGUILayout.LabelField("UID: " + editor.data.uniqueId);
		GUILayout.Space(10);

		XLevelDefine.ElementType newType = (XLevelDefine.ElementType)EditorGUILayout.EnumPopup("type:", editor.data.elementType);
		if (newType != editor.data.elementType)
		{
			editor.data.elementType = newType;
			editor.ChangeType();
		}

		string[] options = null;
		switch(editor.data.elementType)
		{
		//case XLevelDefine.ElementType.SimpleObject:
		//	options = namesOfSimpleObject;
		//	break; 
            case XLevelDefine.ElementType.Unit:
                options = nameOfUnits;
                break;
            case XLevelDefine.ElementType.Defense:
                options = nameOfDefenses;
                break;

         default:
                break;
		}

		if (options != null && options.Length > 0)
		{
			int curSelectIndex = 0;

			
            if (editor.data.elementType == XLevelDefine.ElementType.Defense)
            {
                for (int i = 0; i < idsOfDefenses.Length; i++)
                {
                    if (editor.data.tableId == idsOfDefenses[i])
                    {
                        curSelectIndex = i;
                        break;
                    }
                }
            }
            else if(editor.data.elementType == XLevelDefine.ElementType.Unit)
            {
                for(int i=0 ; i < idsOfUnits.Length ; ++i)
                {
                    if(editor.data.tableId == idsOfUnits[i])
                    {
                        curSelectIndex = i;
                        break;
                    }
                }
            }
			
			else
			{
				for (int i=0; i<options.Length; i++)
				{
					if (editor.data.name == options[i])
					{
						curSelectIndex = i;
						break;
					}
				}
			}

			int newIndex = EditorGUILayout.Popup("name:", curSelectIndex, options);
			if (newIndex != curSelectIndex)
			{
				editor.data.name = options[newIndex];

				
                if (editor.data.elementType == XLevelDefine.ElementType.Defense)
                {
                    editor.data.tableId = idsOfDefenses[newIndex];
                }
                else if(editor.data.elementType == XLevelDefine.ElementType.Unit)
                {
                    editor.data.tableId = idsOfUnits[newIndex];
                }
				editor.ChangeName();
			}
		}
		else
		{
			EditorGUILayout.LabelField("No options in this category.");
		}

        EditorGUILayout.LabelField("Team: ", GUILayout.MaxWidth(120));
        editor.data.teamId = EditorGUILayout.IntField(editor.data.teamId, GUILayout.MaxWidth(120));


		EditorGUILayout.Separator();

		editor.data.activeWhenInitial = EditorGUILayout.Toggle("Active when initial", editor.data.activeWhenInitial);
		editor.data.isGlobal = EditorGUILayout.Toggle("Global Object", editor.data.isGlobal);
		editor.data.isFloatInBeginning = EditorGUILayout.Toggle("Floating In Beginning", editor.data.isFloatInBeginning);

		GUI.color = Color.white;

		EditorGUILayout.Space();

		// show element attribute
		
		

		EditorGUILayout.EndVertical();
	}
	
	void OnSceneGUI()
	{
		if (Application.isPlaying)
		{
			return;
		}

		Handles.Label(editor.transform.position + new Vector3(0,1,0), editor.name, style);

		GUI.Window(0, new Rect(Screen.width - 200, Screen.height - 200, 200, 200), DrawWindow, editor.name);
	}

	void DrawWindow(int _id)
	{
		
	}
}
