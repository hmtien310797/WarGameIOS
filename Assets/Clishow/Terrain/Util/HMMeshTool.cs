using UnityEngine;
using System.Collections;



//仅仅支持pos rotate scale 都是normal值的mesh
public class HMMeshTool
{
    static Vector2 uv;
    static Vector2 buv;
    static Vector3 vpos;
    static Vector3 rpos;
    static Vector3 spos;
    static Color result;
    static TerrainSpriteData sprite;
    public static Vector2 GetWorldToUV(Vector3 wpos, Vector3 _vpos, float fw, Rect r)
    {
        uv.x = wpos.x + _vpos.x;
        uv.y = wpos.z + _vpos.z;
        uv.x = (uv.x - r.xMin) * fw;
        uv.y = (uv.y - r.yMin) * fw;
        uv.x %= 1;
        if (uv.x < 0)
            uv.x += 1;
        uv.y %= 1;
        if (uv.y < 0)
            uv.y += 1;
        return uv;
    }

    static Color tmpColor = Color.white;
    //private static Color toVerticeColor(WorldData world, Vector3 wpos, Vector3 _vpos, Vector4 hr, Rect r, float fw)
    //{
    //    r.Set(wpos.x * hr.x - hr.z, wpos.z * hr.y - hr.w, hr.x, hr.y);
    //    Vector2 uv = GetWorldToUV(wpos, _vpos, fw, r);
    //    int px = (int)((1 - uv.x) * world.HeightMapWidth);
    //    int py = (int)((1 - uv.y) * world.HeightMapHeight);
    //    int index = (world.HeightMapHeight - py) * world.HeightMapWidth + px;
    //    Color result = world.GetHeight(index - 1);
    //    result.b = uv.x;
    //    result.a = uv.y;
    //    return result;
    //}

    private static Vector3[] NDir = new Vector3[] {new Vector3(0,0,1),new Vector3(0,0,-1),
                                                   new Vector3(1,0,0),new Vector3(-1,0,0)};

    public static float Min(float f1, float f2)
    {
        if (f1 < f2) return f1;
        else return f2;
    }

    public static bool isInCoreArea(Vector3 wpos, WorldData world)
    {
        spos.x = wpos.x - world.HRValue.z;
        spos.z = wpos.z - world.HRValue.w;
        //float cx = Mathf.Floor(spos.x / world.HRValue.x);
        float cx = spos.x / world.HRValue.x;
        if (cx >= 0) { cx = (int)cx; } else { cx = (int)cx - 1; }
        //float cy = Mathf.Floor(spos.z / world.HRValue.y);
        float cy = spos.z / world.HRValue.y;
        if (cy >= 0) { cy = (int)cy; } else { cy = (int)cy - 1; }

        //cx = Mathf.Floor(cx % world.LogicServerSize);
        cx = cx % world.LogicServerSize;
        if (cx >= 0) { cx = (int)cx; } else { cx = (int)cx - 1; }
        if (cx < 0)
            cx = world.LogicServerSize + cx;
        //cy = Mathf.Floor(cy % world.LogicServerSize);
        cy = cy % world.LogicServerSize;
        if (cy >= 0) { cy = (int)cy; } else { cy = (int)cy - 1; }
        if (cy < 0)
            cy = world.LogicServerSize + cy;
        //Debug.Log("is Core Area "+cx+","+cy+","+Time.realtimeSinceStartup);
        if ((cx - world.CoreAreaSetting.x + 0.1) > 0 &&
           (cy - world.CoreAreaSetting.y + 0.1) > 0 &&
           (world.CoreAreaSetting.z - cx + 0.1) > 0 &&
           (world.CoreAreaSetting.w - cy + 0.1) > 0)
        {
            return true;
        }
        return false;
    }

    public static bool isInCoreArea(int wv2ix, int wv2iy, WorldData world)
    {
        float cx = wv2ix * world.LogicBlockSize;
        if (cx >= 0) { cx = (int)cx; } else { cx = (int)cx - 1; }
        float cy = wv2iy * world.LogicBlockSize;
        if (cy >= 0) { cy = (int)cy; } else { cy = (int)cy - 1; }
        cx -= world.HRValue.z;
        cy -= world.HRValue.z;
        spos.x = cx;
        spos.z = cy;
        //spos.x = Mathf.FloorToInt(wv2ix * world.LogicBlockSize) - world.HRValue.z;
        //spos.z = Mathf.FloorToInt(wv2iy * world.LogicBlockSize) - world.HRValue.z;
        return isInCoreArea(spos, world);
    }

    public static bool isMainServerBorder(ref int wv2ix, ref int wv2iy, WorldData world)
    {
        if (world.LogicServerSizeX == 0 || world.LogicServerSizeY == 0)
            return false;
        wv2ix = wv2ix % world.LogicServerSizeX;
        if (wv2ix < 0)
        {
            wv2ix = world.LogicServerSizeX + wv2ix;
        }
        wv2iy = wv2iy % world.LogicServerSizeY;
        if (wv2iy < 0)
        {
            wv2iy = world.LogicServerSizeY + wv2iy;
        }
        if (wv2iy == 0 || wv2ix == 0 || wv2ix == world.LogicServerSizeX - 1 || wv2iy == world.LogicServerSizeY - 1)
            return true;
        return false;
    }



    //public static void HeighMap2Mesh(Vector3[] vertices, Vector3[] r_vertces, Color[] colors, Vector3 world_pos, WorldData world, TerrainSpriteChunk tChunk)
    //{
    //    if (vertices == null)
    //        return;
    //    //Rect r = new Rect(0, 0, heigh_range.width, heigh_range.height);

    //    int hmw = world.HeightMapWidth;
    //    int hmh = world.HeightMapHeight;

    //    Vector4 hr = world.HRValue;
    //    Vector2 hr1_5 = world.HRValue1_5;
    //    float fw = world.FWValue;
    //    float blendx = world.BlendRange.x;
    //    float blendy = world.BlendRange.y;
    //    int serverSize = world.LogicServerSize;
    //    bool isCoreArea = false;
    //    bool blend = false;
    //    float uvx, uvy;
    //    int min_ca_x = (int)world.CoreAreaSetting.x;
    //    int min_ca_y = (int)world.CoreAreaSetting.y;
    //    int max_ca_x = (int)world.CoreAreaSetting.z;
    //    int max_ca_y = (int)world.CoreAreaSetting.w;
    //    float cx, cy;
    //    Color[] hcolors = world.HeightMap;
    //    //isInCoreArea(world_pos,world);
    //    for (int i = 0, imax = vertices.Length; i < imax; i++)
    //    {
    //        isCoreArea = false;
    //        //colors[i] = toVerticeColor(world,world_pos, vertices[i], hr,r,fw);
    //        vpos = vertices[i];
    //        rpos.x = world_pos.x + vpos.x;
    //        rpos.y = vpos.y;
    //        rpos.z = world_pos.z + vpos.z;
    //        spos.x = rpos.x - hr.z;
    //        spos.z = rpos.z - hr.w;
    //        cx = spos.x / hr.x;
    //        if (cx >= 0) { cx = (int)cx; } else { cx = (int)cx - 1; }
    //        cy = spos.z / hr.y;
    //        if (cy >= 0) { cy = (int)cy; } else { cy = (int)cy - 1; }

    //        cx = cx % serverSize;
    //        if (cx >= 0) { cx = (int)cx; } else { cx = (int)cx - 1; }
    //        //cx =  (float)System.Math.Floor((double)(spos.x / hr.x));
    //        //cy = (float)System.Math.Floor((double)(spos.z / hr.y));
    //        //cx = (float)System.Math.Floor((double)(cx % serverSize));
    //        if (cx < 0)
    //            cx = serverSize + cx;

    //        cy = cy % serverSize;
    //        if (cy >= 0) { cy = (int)cy; } else { cy = (int)cy - 1; }
    //        //cy = (float)System.Math.Floor((double)(cy % serverSize));
    //        if (cy < 0)
    //            cy = serverSize + cy;
    //        if ((cx - min_ca_x + 0.1) > 0 &&
    //           (cy - min_ca_y + 0.1) > 0 &&
    //           (max_ca_x - cx + 0.1) > 0 &&
    //           (max_ca_y - cy + 0.1) > 0)
    //        {
    //            isCoreArea = true;
    //        }
    //        uvx = (spos.x) * fw;
    //        uvy = (spos.z) * fw;
    //        //uvx = (rpos.x) * fw;
    //        //uvy = (rpos.z) * fw;
    //        uv.x = uvx;
    //        uv.y = uvy;
    //        uv.x = uv.x - (int)uv.x;
    //        if (uv.x < 0)
    //            uv.x += 1;
    //        uv.y = uv.y - (int)uv.y;
    //        if (uv.y < 0)
    //            uv.y += 1;
    //        blend = false;
    //        buv = uv;
    //        if (uv.x < blendx || 1 - uv.x < blendx)
    //        {
    //            buv.x = 1.0f - uv.x;
    //            blend = true;
    //        }
    //        if (uv.y < blendy || 1 - uv.y < blendy)
    //        {
    //            buv.y = 1 - uv.y;
    //            blend = true;
    //        }

    //        //int px = Mathf.Min((int)((1 - uv.x) * hmw), hmw - 1);
    //        int px = (int)((1 - uv.x) * hmw);
    //        if (px > hmw - 1)
    //            px = hmw - 1;
    //        //int py = Mathf.Min((int)((1 - uv.y) * hmh), hmw - 1);
    //        int py = (int)((1 - uv.y) * hmh);
    //        if (py > hmh - 1)
    //            py = hmh - 1;
    //        int index = (hmw - px - 1) * hmh + py + 1;
    //        if (blend)
    //        {
    //            //int bpx = Mathf.Min((int)((1 - buv.x) * hmw), hmw - 1);
    //            int bpx = (int)((1 - buv.x) * hmw);
    //            if (bpx > hmw - 1)
    //                bpx = hmw - 1;
    //            //int bpy = Mathf.Min((int)((1 - buv.y) * hmh), hmw - 1);
    //            int bpy = (int)((1 - buv.y) * hmh);
    //            if (bpy > hmh - 1)
    //                bpy = hmh - 1;
    //            int bindex = (hmw - bpx - 1) * hmh + bpy + 1;
    //            result = hcolors[index - 1];
    //            result = Color.Lerp(result, hcolors[bindex - 1], 0.5f);
    //        }
    //        else
    //        {
    //            result = hcolors[index - 1];
    //        }
    //        result.b = uvx;// - (int)uvx;
    //        result.a = uvy;// - (int)uvy;
    //        if (isCoreArea)
    //        {
    //            rpos.y += world.GroundHeight;
    //        }
    //        else
    //            rpos.y += result.r * world.TerrainMaxHeight;
    //        colors[i] = result;
    //        r_vertces[i] = rpos;
    //    }
    //}

    public static void HeighMap2MeshSimple(Vector3[] vertices, Vector3[] r_vertces, Vector3 world_pos, WorldData world)
    {
        if (vertices == null)
            return;
        float fw = world.FWValue;
        float uvx, uvy;
        for (int i = 0, imax = vertices.Length; i < imax; i++)
        {
            vpos = vertices[i];
            rpos.x = world_pos.x + vpos.x;
            rpos.y = vpos.y;
            rpos.z = world_pos.z + vpos.z;
            uvx = (spos.x) * fw;
            uvy = (spos.z) * fw;
            result.r = 0;
            result.g = 0;
            result.b = uvx;
            result.a = uvy;
            r_vertces[i] = rpos;
        }
    }
}
