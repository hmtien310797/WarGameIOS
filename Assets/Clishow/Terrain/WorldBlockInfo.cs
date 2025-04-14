using UnityEngine;
using System.Collections;

[System.Serializable]
public class WorldBlockInfo : ScriptableObject, ISerializationCallbackReceiver
{
    [SerializeField]
    private int worldSize = 512;
    /// <summary>
    /// 地图阻挡信息（不用于序列化）
    /// </summary>
    private int[,] isOccupied;

    /// <summary>
    /// 地图阻挡信息原始数据（用于序列化）
    /// </summary>
    [SerializeField]
    private int[] isOccupied_rawData;

    public int width
    {
        get
        {
            return worldSize;
        }
    }

    public int height
    {
        get
        {
            return worldSize;
        }
    }

    public int this[int x, int y]
    {
        get
        {
            return isOccupied[x % worldSize, y % worldSize];
        }
    }

    public void Build(int worldSize, int[] isOccupied_rawData)
    {
        this.worldSize = worldSize;
        this.isOccupied_rawData = isOccupied_rawData;

        OnAfterDeserialize();
    }

    /**************************************
     *   ISerializationCallbackReceiver   *
     **************************************/

    public void OnBeforeSerialize()
    {
        return;
    }

    public void OnAfterDeserialize()
    {
		isOccupied = new int[worldSize, worldSize];
        for (int i = 0; i < isOccupied_rawData.Length; i++)
			isOccupied[worldSize - 1 - ((isOccupied_rawData[i] >> 9) & 0x1ff), worldSize - 1 - (isOccupied_rawData[i] & 0x1ff)] = isOccupied_rawData[i] >> 18;

        for (int i = 0; i < worldSize; i++)
            isOccupied[0, i] = isOccupied[worldSize - 1, i] = isOccupied[i, 0] = isOccupied[i, worldSize - 1] = 1;
    }
}
