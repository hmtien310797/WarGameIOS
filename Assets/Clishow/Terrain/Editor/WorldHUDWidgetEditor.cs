using UnityEngine;
using UnityEditor;
using System.Collections;

public class WorldHUDWidgetEditor
{
    private static GameObject selectedGameObject = null;

    [MenuItem("GameObject/UI/WorldHUD/Badge")]
    public static void CreateBadge()
    {
        GameObject badge = new GameObject();
        badge.AddComponent<WorldHUDBadge>();
        badge.transform.name = "new badge";
        if (selectedGameObject != null)
        {
            badge.transform.parent = selectedGameObject.transform;
            selectedGameObject = null;

            badge.transform.localPosition = Vector3.zero;
            badge.transform.localScale = Vector3.one;
        }

        GameObject background = new GameObject();
        background.AddComponent<UnityEngine.UI.Image>();
        background.GetComponent<UnityEngine.UI.Image>().raycastTarget = false;
        background.transform.name = "background";
        background.transform.parent = badge.transform;
        background.transform.localPosition = Vector3.zero;
        background.transform.localScale = Vector3.one;

        GameObject icon = new GameObject();
        icon.AddComponent<UnityEngine.UI.Image>();
        background.GetComponent<UnityEngine.UI.Image>().raycastTarget = false;
        icon.transform.name = "icon";
        icon.transform.parent = badge.transform;
        icon.transform.localPosition = Vector3.zero;
        icon.transform.localScale = Vector3.one;
    }

    [MenuItem("GameObject/UI/WorldHUD/Label")]
    public static void CreateLabel()
    {
        GameObject label = new GameObject();
        label.AddComponent<WorldHUDLabel>();
        label.transform.name = "new label";
        if (selectedGameObject != null)
        {
            label.transform.parent = selectedGameObject.transform;
            selectedGameObject = null;

            label.transform.localScale = Vector3.zero;
            label.transform.localScale = Vector3.one;
        }

        GameObject background = new GameObject();
        background.AddComponent<UnityEngine.UI.Image>();
        background.GetComponent<UnityEngine.UI.Image>().raycastTarget = false;
        background.transform.name = "background";
        background.transform.parent = label.transform;
        background.transform.localPosition = Vector3.zero;
        background.transform.localScale = Vector3.one;


        GameObject text = new GameObject();
        text.AddComponent<UnityEngine.UI.Text>();
        text.GetComponent<UnityEngine.UI.Text>().raycastTarget = false;
        text.transform.name = "text";
        text.transform.parent = label.transform;
        text.transform.localPosition = Vector3.zero;
        text.transform.localScale = Vector3.one;
    }

    [MenuItem("GameObject/UI/WorldHUD/Bubble")]
    public static void CreateBubble()
    {
        GameObject bubble = new GameObject();
        bubble.AddComponent<WorldHUDBubble>();
        bubble.transform.name = "new label";
        if (selectedGameObject != null)
        {
            bubble.transform.parent = selectedGameObject.transform;
            selectedGameObject = null;

            bubble.transform.localScale = Vector3.zero;
            bubble.transform.localScale = Vector3.one;
        }

        GameObject type0 = new GameObject();
        type0.AddComponent<UnityEngine.UI.Image>();
        type0.GetComponent<UnityEngine.UI.Image>().raycastTarget = false;
        type0.transform.name = "0.";
        type0.transform.parent = bubble.transform;
        type0.transform.localPosition = Vector3.zero;
        type0.transform.localScale = Vector3.one;
    }

    [MenuItem("GameObject/UI/WorldHUD/Bar")]
    public static void CreateBar()
    {
        GameObject bar = new GameObject();
        bar.AddComponent<WorldHUDLabel>();
        bar.transform.name = "new bar";
        if (selectedGameObject != null)
        {
            bar.transform.parent = selectedGameObject.transform;
            selectedGameObject = null;

            bar.transform.localScale = Vector3.zero;
            bar.transform.localScale = Vector3.one;
        }

        GameObject filling = new GameObject();
        filling.AddComponent<UnityEngine.UI.Image>();
        filling.GetComponent<UnityEngine.UI.Image>().raycastTarget = false;
        filling.transform.name = "filling";
        filling.transform.parent = bar.transform;
        filling.transform.localPosition = Vector3.zero;
        filling.transform.localScale = Vector3.one;


        GameObject frame = new GameObject();
        frame.AddComponent<UnityEngine.UI.Image>();
        frame.GetComponent<UnityEngine.UI.Image>().raycastTarget = false;
        frame.transform.name = "frame";
        frame.transform.parent = bar.transform;
        frame.transform.localPosition = Vector3.zero;
        frame.transform.localScale = Vector3.one;
    }

    [InitializeOnLoadMethod]
    public static void Initialize()
    {
        EditorApplication.hierarchyWindowItemOnGUI += OnHierarchyGUI;
    }

    public static void OnHierarchyGUI(int id, Rect selection)
    {
        if (Event.current != null && selection.Contains(Event.current.mousePosition) && Event.current.button == 1 && Event.current.type <= EventType.MouseUp)
            selectedGameObject = EditorUtility.InstanceIDToObject(id) as GameObject;
    }
}
