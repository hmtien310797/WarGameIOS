using UnityEngine;
using System.Collections;
using System.Collections.Generic;
#if UNITY_EDITOR
[ExecuteInEditMode]
public class XElementRootHelper : MonoBehaviour
{
	// cannot move
	void Update()
	{
        if (Application.isPlaying)
            return;

		Transform t = transform;
		if (t.hasChanged)
		{
			t.position = Vector3.zero;
			t.rotation = Quaternion.identity;
			t.localScale = Vector3.one;
			t.hasChanged = false;
		}
	}

	public void InsertNewElementAt(int _newElementIndex)
	{
        XLevelDataXML levelData = XEditorManager.instance.CurLevelDataXml;

		// create new Element data
		XElementData newElement = new XElementData();
		newElement.uniqueId = XEditorManager.instance.GetNewUniqueIdForElement();
		newElement.elementType = XLevelDefine.ElementType.Defense;
		newElement.name = "Cube";
		newElement.activeWhenInitial = true;
		newElement.isGlobal = false;
		newElement.linkedElementsUID = new int[0];
		newElement.position = Vector3.zero;
        newElement.forward = Vector3.zero;
		newElement.scale = Vector3.one;

		// construct new elements array
		XElementData[] newElements = new XElementData[levelData.elementsData.Length + 1];
		for (int i=0, j=0; i<newElements.Length; i++)
		{
			if (i != _newElementIndex)
			{
				newElements[i] = levelData.elementsData[j++];
			}
		}
		newElements[_newElementIndex] = newElement;
		levelData.elementsData = newElements;
        levelData.ResetElementList();

		// create LevelElement Object
		XLevelElement element = newElement.Instantiate();
		if (element)
		{
			element.transform.parent = XEditorManager.instance.elementRoot;
			
			//Add Editor Component
			XElementEditor elementEditor = element.gameObject.AddComponent<XElementEditor>();
			elementEditor.Init(newElement);

			// Add to Editor Manager
			List<XElementEditor> allelements = XEditorManager.instance.GetAllElements();
			if (allelements != null)
			{
				allelements.Add(elementEditor);
			}

		}
	}
	
	public void CloneElement(int _elementIndex)
	{
		int _newElementIndex = _elementIndex + 1;
        XLevelDataXML levelData = XEditorManager.instance.CurLevelDataXml;
		
		// clone new Group data from exist
		XElementData newElement = levelData.elementsData[_elementIndex].Clone();
		newElement.uniqueId = XEditorManager.instance.GetNewUniqueIdForElement();
		
		// construct new elements array
		XElementData[] newElements = new XElementData[levelData.elementsData.Length + 1];
		for (int i=0, j=0; i<newElements.Length; i++)
		{
			if (i != _newElementIndex)
			{
				newElements[i] = levelData.elementsData[j++];
			}
		}
		newElements[_newElementIndex] = newElement;
		levelData.elementsData = newElements;
        levelData.ResetElementList();
		// create LevelElement Object
		XLevelElement element = newElement.Instantiate();
		if (element)
		{
			element.transform.parent = XEditorManager.instance.elementRoot;
			
			//Add Editor Component
			XElementEditor elementEditor = element.gameObject.AddComponent<XElementEditor>();
			elementEditor.Init(newElement);

			// Add to Editor Manager
			List<XElementEditor> allelements = XEditorManager.instance.GetAllElements();
			if (allelements != null)
			{
				allelements.Add(elementEditor);
			}
		}
	}
	
	public void RemoveElement(int _elementIndex)
	{
        XLevelDataXML levelData = XEditorManager.instance.CurLevelDataXml;
		int elementUID = levelData.elementsData[_elementIndex].uniqueId;
		
		// construct new elements array
		XElementData[] newElements = new XElementData[levelData.elementsData.Length - 1];
		for (int i=0, j=0; i<levelData.elementsData.Length; i++)
		{
			if (i != _elementIndex)
			{
				newElements[j++] = levelData.elementsData[i];
			}
		}
		levelData.elementsData = newElements;
        levelData.ResetElementList();

		// Find the LevelElement Object
		XElementEditor[] elements = GetComponentsInChildren<XElementEditor>(true);
		for (int i=0; i<elements.Length; i++)
		{
			if (elements[i].data.uniqueId == elementUID)
			{
				DestroyImmediate(elements[i].gameObject);
				break;
			}
		}

		// Remove to Editor Manager
		List<XElementEditor> allelements = XEditorManager.instance.GetAllElements();
		if (allelements != null)
		{
			for (int i=allelements.Count-1; i>=0; i--)
			{
				if (allelements[i] == null)
				{
					allelements.RemoveAt(i);
				}
			}
		}
	}
}
#endif