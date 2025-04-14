using UnityEngine;
using System.Collections;
using UnityEditor;
using System.Collections.Generic;
using System.Text;

public class UIUtility
{
    static void MakeFindCode(bool hasFormat)
    {
        var transform = Selection.activeTransform;
        List<string> nameList = new List<string>();
        while (transform != null && transform.GetComponent<LuaBehaviour>() == null)
        {
            nameList.Add(transform.name);
            transform = transform.parent;
        }

        if (nameList.Count > 0)
        {
            nameList.Reverse();
            StringBuilder codeBuilder;
            if (hasFormat)
            {
                codeBuilder = new StringBuilder("transform:Find(string.format(\"");

            }
            else
            {
                codeBuilder = new StringBuilder("transform:Find(\"");

            }
            bool root = true;
            foreach (var name in nameList)
            {
                if (root)
                {
                    codeBuilder.Append(name);
                    root = false;
                }
                else
                {
                    codeBuilder.Append("/" + name);
                }
            }
            if (hasFormat)
            {
                codeBuilder.Append("\"))");
            }
            else
            {
                codeBuilder.Append("\")");
            }
            string codeString = codeBuilder.ToString();
            NGUITools.clipboard = codeString;
            Debug.Log(codeString);
        }
    }

    [MenuItem("Tools/Make UI Find Code %&i")]
    static void MakeUIFindCode()
    {
        MakeFindCode(false);
    }

    [MenuItem("Tools/Make UI Find Format Code %&c")]
    static void MakeFormatUIFindCode()
    {
        MakeFindCode(true);
    }

    [MenuItem("Tools/ChangeAnchorFlag")]
    static void ChangeAnchorFlag()
    {
        if (Selection.activeGameObject == null)
        {
            Debug.Log("ChangeAnchorFlag Error: Choose A GameObject First . ");
            return;
        }

        checkRecursive("" , Selection.activeGameObject);
    }

   static void checkRecursive(string parentName, GameObject parentObject)
    {
        if (parentObject == null)
            return;

        string path = parentName + "/" + parentObject.name;

        foreach (Transform child in parentObject.transform)
        {
            UIWidget uW = child.GetComponent<UIWidget>();
            if(uW && uW.updateAnchors == UIRect.AnchorUpdate.OnUpdate)
            {
                Debug.Log("ChangeAnchorFlag Recursive：ob name: " + path);
                uW.updateAnchors = UIRect.AnchorUpdate.OnEnable;
            }
           
            checkRecursive(path, child.gameObject);
        }
    }
}
