using UnityEngine;
using System.Collections;

public class CustomSortUIGrid : UIGrid
{
    void Start()
    {

    }
    protected override void Sort(System.Collections.Generic.List<Transform> list)
    {
        if (sorting == Sorting.Custom)
            list.Sort(this.SortByLevelID);
    }
    int SortByLevelID(Transform a, Transform b)
    {
        int va = int.Parse(a.gameObject.name);
        int vb = int.Parse(b.gameObject.name);
        return va.CompareTo(vb);
    }

    // Update is called once per frame  
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.A))
            this.Reposition();

    }
}
