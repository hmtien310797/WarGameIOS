using UnityEngine;
using System.Collections.Generic;

/// <summary>
/// 3D大地图数据文件
/// </summary>
[System.Serializable]
public class World3D : ScriptableObject
{
    /// <summary>
    /// 地图大小（图块）
    /// </summary>
    public short size;

    /// <summary>
    /// 世界图块大小
    /// </summary>
    [SerializeField]
    private byte tileSize;

    /// <summary>
    /// KDTree数据结构 (地表、山、水)
    /// </summary>
    [SerializeField]
    private WorldObject[] objects;

    /// <summary>
    /// 数据中所有WorldObject类的极限尺寸
    /// </summary>
    [SerializeField]
    private short[] maxObjectSize;

    public int width
    {
        get
        {
            return size;
        }
    }

    public int height
    {
        get
        {
            return size;
        }
    }


    /************
     *   APIs   *
     ************/

    /// <summary>
    /// 根据给定数据构造World3D类
    /// </summary>
    /// <param name="size">世界大小</param>
    /// <param name="objects">世界所包含的所有WorldObject类</param>
    /// <param name="maxObjectWidth">所有WorldObject类的极限宽度（X差值</param>
    /// <param name="maxObjectHeight">所有WorldObject类的极限高度（Y差值）</param>
    /// <param name="tileSize">地图图块大小</param>
    public void Build(int size, WorldObject[] objects, int maxObjectWidth, int maxObjectHeight, int tileSize)
    {
        this.size = (short)size;
        this.objects = objects;
        this.maxObjectSize = new short[2] { (short)maxObjectHeight, (short)maxObjectWidth };
        this.tileSize = (byte) tileSize;

        Build(0, objects.Length - 1, 0);
    }

    /// <summary>
    /// 搜索给定矩形范围内所有WorldObject类并填充至给定数组中
    /// </summary>
    /// <param name="minX">给定矩形范围的X最小值</param>
    /// <param name="minY">给定矩形范围的Y最小值</param>
    /// <param name="maxX">给定矩形范围的X最大值</param>
    /// <param name="maxY">给定矩形范围的Y最大值</param>
    /// <param name="array">被填充的数组</param>
    /// <returns>给定矩形范围内所有WorldObject类的数量</returns>
    public int GetObjects(int minX, int minY, int maxX, int maxY, WorldObject[] array)
    {
        int worldSize = size * tileSize;

        minX %= worldSize;
        if (minX < 0)
            minX += worldSize;

        minY %= worldSize;
        if (minY < 0)
            minY += worldSize;

        maxX %= worldSize;
        if (maxX < 0)
            maxX += worldSize;

        maxY %= worldSize;
        if (maxY < 0)
            maxY += worldSize;

        int count = 0;
        GetObjects(0, objects.Length - 1, 0, new int[2] { minX, minY }, new int[2] { maxX, maxY }, array, ref count);

        return count;
    }



    /************************
     *   Helper Functions   * 
     ************************/

    /// <summary>
    /// 在objects数组的给定范围内构造KDTree数据结构
    /// </summary>
    /// <param name="left">给定范围的下标最小值</param>
    /// <param name="right">给定范围的下标最大值</param>
    /// <param name="dim">当前空间维度</param>
    private void Build(int left, int right, int dim)
    {
        if (left >= right)
            return;

        int mid = (left + right) / 2;

        QuickSelect(left, right, mid, dim);

        dim = (dim + 1) % 2;

        Build(left, mid - 1, dim);
        Build(mid + 1, right, dim);
    }

    /// <summary>
    /// 快速选择算法：在objects数组的给定范围内选择第n个数据（排序状态下）
    /// </summary>
    /// <param name="left">给定范围的下标最小值</param>
    /// <param name="right">给定范围的下标最大值</param>
    /// <param name="n">需要选择的数据下标</param>
    /// <param name="dim">当前空间维度</param>
    private void QuickSelect(int left, int right, int n, int dim)
    {
        if (left >= right)
            return;

        int pivot = Partition(left, right, dim);

        if (n == pivot)
            return;
        else if (n < pivot)
            QuickSelect(left, pivot - 1, n, dim);
        else
            QuickSelect(pivot + 1, right, n, dim);
    }

    /// <summary>
    /// 快速选择算法-分区函数：将objects数组给定范围内的数据根据pivot分成两部分
    /// </summary>
    /// <param name="left">给定范围的下标最小值</param>
    /// <param name="right">给定范围的下标最大值</param>
    /// <param name="dim">当前空间维度</param>
    /// <returns>数组中pivot的下标</returns>
    private int Partition(int left, int right, int dim)
    {
        if (right - left > 1)
            Swap((left + right) / 2, right);

        int j = left;
        for (int i = left; i < right; i++)
            if (objects[i].SmallerThan(objects[right], dim))
                Swap(i, j++);

        Swap(right, j);

        return j;
    }

    /// <summary>
    /// 快速选择算法-交换函数：将objects数组中位于两个不同下标的数据交换
    /// </summary>
    /// <param name="i">被交换数据的下标1</param>
    /// <param name="j">被交换数据的下标2</param>
    private void Swap(int i, int j)
    {
        if (i == j)
            return;

        WorldObject temp = objects[i];
        objects[i] = objects[j];
        objects[j] = temp;
    }

    /// <summary>
    /// 在objects数组的给定范围中根据KDTree数据结构搜索在给定矩形范围内所有WolrdObjects类并填充至给定数组中
    /// </summary>
    /// <param name="left">给定数组范围的下标最小值</param>
    /// <param name="right">给定数组范围的下标最大值</param>
    /// <param name="dim">当前空间维度</param>
    /// <param name="min">给定矩形范围的XY最小值</param>
    /// <param name="max">给定矩形范围的XY最大值</param>
    /// <param name="array">被填充的数组</param>
    /// <param name="count">被填充数组中被填充的WorldObject类的数量</param>
    private void GetObjects(int left, int right, int dim, int[] min, int[] max, WorldObject[] array, ref int count)
    {
        if (max[dim] < min[dim])
        {
            int temp = max[dim];
            max[dim] = size * tileSize;

            GetObjects(left, right, dim, min, max, array, ref count);

            min[dim] = 0;
            max[dim] = temp;

            GetObjects(left, right, dim, min, max, array, ref count);
        }
        else
        {
            int mid = (left + right) / 2;

            WorldObject obj = objects[mid];
            if (obj.IsOverlapped(min, max, tileSize))
            {
                if (count == array.Length)
                    return;

                array[count++] = obj;
            }

            if (left < right)
            {
                float pivot = obj.pos[dim];

                if (pivot >= min[dim] - maxObjectSize[dim] / 2)
                    GetObjects(left, mid - 1, (dim + 1) % 2, min, max, array, ref count);
                if (pivot <= max[dim] + maxObjectSize[dim] / 2)
                    GetObjects(mid + 1, right, (dim + 1) % 2, min, max, array, ref count);
            }
        }
    }
}
