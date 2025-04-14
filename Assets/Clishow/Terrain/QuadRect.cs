using UnityEngine;
using System.Collections;

public struct QuadRect
{

    public float Width;
    public float Height;
    public Vector3 MinPoint;
    public Vector3 MaxPoint;
    public Vector3 CenterPoint;

    public float X;
    public float Y;
    public float MinX;
    public float MinY;
    public float MaxX;
    public float MaxY;
    private Vector3 tmp;
    public QuadRect(float x, float y, float width, float height)
    {
        tmp = Vector3.zero;
        MinPoint = Vector3.zero;
        MaxPoint = Vector3.zero;
        CenterPoint = Vector3.zero;
        X = x;
        Y = y;
        Width = width;
        Height = height;
        MinX = 0;
        MinY = 0;
        MaxX = 0;
        MaxY = 0;
        Refrush();
    }

    public void SetPos(float x, float y)
    {
        X = x;
        Y = y;
        Refrush();
    }

    public bool Intersects(ref QuadRect other)
    {
        return MinX < other.MaxX && MinY < other.MaxY && MaxX > other.MinX && MaxY > other.MinY;
    }

    public bool Contains(ref QuadRect other)
    {
        return other.MinX >= MinX && other.MinY >= MinY && other.MaxX <= MaxX && other.MaxY <= MaxY;
    }

    private void Refrush()
    {
        MinX = X - Width * 0.5f;
        MinY = Y - Height * 0.5f;
        MaxX = X + Width * 0.5f;
        MaxY = Y + Height * 0.5f;
        MinPoint.x = MinX;
        MinPoint.y = 0;
        MinPoint.z = MinY;
        MaxPoint.x = MaxX;
        MaxPoint.y = 0;
        MaxPoint.z = MaxY;
        CenterPoint.x = X;
        CenterPoint.z = Y;
    }

}