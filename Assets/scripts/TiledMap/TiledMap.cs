using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class TiledMap : UIWidget
{
    public class Tile
    {
        public string sprite;

        public Color color;

        public bool visible;
    }

    [HideInInspector]
    [SerializeField]
    UIAtlas mAtlas;

    public int mapSize = 44;
    public int tileWidth = 60;
    public int tileHeight = 40;

    private Dictionary<string, Vector4> uvList;
    private Dictionary<string, Vector4> vertList;

    private Tile[,] tileList;

    public override Material material { get { return (mAtlas != null) ? mAtlas.spriteMaterial : null; } }

    protected override void Awake()
    {
        base.Awake();
        if (mAtlas != null && uvList == null)
        {
            uvList = new Dictionary<string, Vector4>();
            vertList = new Dictionary<string, Vector4>();
            Texture tex = mainTexture;
            float texWidth = tex.width;
            float texHeight = tex.height;

            foreach (var spriteData in mAtlas.spriteList)
            {
                Rect outer = new Rect(spriteData.x, spriteData.y, spriteData.width, spriteData.height);

                outer = NGUIMath.ConvertToTexCoords(outer, tex.width, tex.height);

                Vector4 uv = new Vector4(outer.xMin, outer.yMin, outer.xMax, outer.yMax);

                float x0 = -tileWidth * 0.5f;
                float y0 = -tileHeight * 0.5f;
                float x1 = x0 + tileWidth;
                float y1 = y0 + tileHeight;

                int padLeft = spriteData.paddingLeft;
                int padBottom = spriteData.paddingBottom;
                int padRight = spriteData.paddingRight;
                int padTop = spriteData.paddingTop;

                int w = spriteData.width + padLeft + padRight;
                int h = spriteData.height + padBottom + padTop;
                float px = 1f;
                float py = 1f;

                if (w > 0 && h > 0)
                {
                    if ((w & 1) != 0) ++padRight;
                    if ((h & 1) != 0) ++padTop;

                    px = (1f / w) * tileWidth;
                    py = (1f / h) * tileHeight;
                }

                x0 += padLeft * px;
                x1 -= padRight * px;

                y0 += padBottom * py;
                y1 -= padTop * py;
                float pixelSize = mAtlas != null ? mAtlas.pixelSize : 1f;
                Vector4 br = (mAtlas != null) ? border * pixelSize : Vector4.zero;

                float fw = br.x + br.z;
                float fh = br.y + br.w;

                float vx = Mathf.Lerp(x0, x1 - fw, mDrawRegion.x);
                float vy = Mathf.Lerp(y0, y1 - fh, mDrawRegion.y);
                float vz = Mathf.Lerp(x0 + fw, x1, mDrawRegion.z);
                float vw = Mathf.Lerp(y0 + fh, y1, mDrawRegion.w);

                Vector4 vert = new Vector4(vx, vy, vz, vw);

                uvList.Add(spriteData.name, uv);
                vertList.Add(spriteData.name, vert);
            }

            float halfTileWidth = tileWidth * 0.5f;
            float halfTileHeight = tileHeight * 0.5f;

            tileList = new Tile[mapSize, mapSize];
            for (int mapY = 0; mapY < mapSize; mapY++)
            {
                for (int mapX = 0; mapX < mapSize; mapX++)
                {
                    tileList[mapY, mapX] = new Tile();
                    Tile tile = tileList[mapY, mapX];
#if UNITY_EDITOR
                    if (mAtlas != null)
                    {
                        tile.sprite = mAtlas.GetListOfSprites()[0];
                        tile.visible = true;
                        tile.color = Color.white;
                    }
#endif
                }
            }
        }
    }

    public void HideAllTile()
    {
        for (int mapY = 0; mapY < mapSize; mapY++)
        {
            for (int mapX = 0; mapX < mapSize; mapX++)
            {
                tileList[mapY, mapX].visible = false;
            }
        }
    }

    public void SetTile(int mapX, int mapY, string sprite, Color color, bool visible)
    {
        tileList[mapY, mapX].visible = visible;
        if (visible)
        {
            tileList[mapY, mapX].sprite = sprite;
            tileList[mapY, mapX].color = color;
        }
    }

    public override void OnFill(BetterList<Vector3> verts, BetterList<Vector2> uvs, BetterList<Color32> cols)
    {
        if (mAtlas == null)
        {
            return;
        }

        int offset = verts.size;

        for (int mapY = 0; mapY < mapSize; mapY++)
        {
            for (int mapX = 0; mapX < mapSize; mapX++)
            {
                Tile tile = tileList[mapY, mapX];
                if (tile.visible)
                {
                    string sprite = tile.sprite;
                    Color32 color = tile.color;
                    Vector4 uv = uvList[sprite];
                    Vector4 vert = vertList[sprite];

                    float x = tileWidth * (mapX - mapY) * 0.5f;
                    float y = tileHeight * (mapX + mapY) * 0.5f;

                    verts.Add(new Vector3(vert.x + x, vert.y + y));
                    verts.Add(new Vector3(vert.x + x, vert.w + y));
                    verts.Add(new Vector3(vert.z + x, vert.w + y));
                    verts.Add(new Vector3(vert.z + x, vert.y + y));

                    uvs.Add(new Vector2(uv.x, uv.y));
                    uvs.Add(new Vector2(uv.x, uv.w));
                    uvs.Add(new Vector2(uv.z, uv.w));
                    uvs.Add(new Vector2(uv.z, uv.y));

                    cols.Add(color);
                    cols.Add(color);
                    cols.Add(color);
                    cols.Add(color);
                }
            }
        }

        if (onPostFill != null)
            onPostFill(this, offset, verts, uvs, cols);
    }
}
