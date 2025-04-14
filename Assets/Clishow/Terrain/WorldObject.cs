using UnityEngine;
using System.Collections;

public enum WorldObjectType
{
    ALL,
    TERRAIN,
    BIOME
}

[System.Serializable]
public struct WorldObject
{
    public byte id;

    public byte width;
    public byte height;

    private byte padding;

    public short[] pos;

    /// <summary>
    /// X坐标
    /// </summary>
    public float worldX
    {
        get
        {
            return pos[0];
        }
    }

    /// <summary>
    /// Z坐标
    /// </summary>
    public float worldZ
    {
        get
        {
            return pos[1];
        }
    }

    public WorldObject(byte id, int width, int height, short x, short y)
    {
        this.id = id;
        this.width = (byte)width;
        this.height = (byte)height;
        this.padding = 0;
        this.pos = new short[2] { (short)x, (short)y };
    }

    /// <summary>
    /// 判断两个WorldObject类在当前空间空间维度的大小
    /// </summary>
    /// <param name="other">被比较的WorldObject类</param>
    /// <param name="dim">当前空间维度</param>
    /// <returns>是否在当前空间维度小于被比较的WorldObject类</returns>
    public bool SmallerThan(WorldObject other, int dim)
    {
        if (this.pos[dim] == other.pos[dim])
            return this.pos[(dim + 1) % 2] < other.pos[(dim + 1) % 2];

        return this.pos[dim] < other.pos[dim];
    }

    /// <summary>
    /// 判断是否与给定矩形范围重叠
    /// </summary>
    /// <param name="min">给定矩形范围XY最小值</param>
    /// <param name="max">给定矩形范围XY最大值</param>
    /// <param name="tileSize">世界图块大小</param>
    /// <returns>是否与给定矩形范围重叠</returns>
    public bool IsOverlapped(int[] min, int[] max, int tileSize)
    {
        int x = pos[0];
        int y = pos[1];
        int dx = height * tileSize / 2;
        int dy = width * tileSize / 2;

        return !(max[0] < x - dx || min[0] > x + dx || max[1] < y - dy || min[1] > y + dy);
    }
}
