using UnityEngine;
using System.Collections;

public class WorldUI : MonoBehaviour
{
    public UILabel Tips;
    public UIButton[] Btns;

    [System.NonSerialized]
    public bool DeleteSpriteTag = false;
    [System.NonSerialized]
    public bool OpenBlockRect = false;
    [System.NonSerialized]
    public bool Occupy = false;
    [System.NonSerialized]
    public bool DebugBlock = false;
    [System.NonSerialized]
    public World world;

    private UISprite[] mBtnSprites;
    // Use this for initialization
    void Start()
    {
        mBtnSprites = new UISprite[Btns.Length];
        for (int i = 0; i < Btns.Length; i++)
        {
            mBtnSprites[i] = Btns[i].GetComponent<UISprite>();
        }
        SetTips();
        UpdateBtns();
    }

    private string defualt = "无";

    public void SetTips(string tips = "")
    {
        if (string.IsNullOrEmpty(tips))
        {
            Tips.text = defualt;
        }
        else
            Tips.text = tips;
    }

    public void UpdateBtns()
    {
        Btns[0].normalSprite = DeleteSpriteTag ? "btn_1" : "btn_2";
        Btns[1].normalSprite = OpenBlockRect ? "btn_1" : "btn_2";
        Btns[2].normalSprite = Occupy ? "btn_1" : "btn_2";
        Btns[3].normalSprite = DebugBlock ? "btn_1" : "btn_2";
        Btns[4].normalSprite = EnableDetal8 ? "btn_1" : "btn_2";
        Btns[5].normalSprite = EnableWaterRefl ? "btn_1" : "btn_2";
        Btns[6].normalSprite = EnableWaterSpec ? "btn_1" : "btn_2";
        Btns[7].normalSprite = EnableLine ? "btn_1" : "btn_2";
    }

    public void OnClick_DeleteSpriteTag()
    {
        EnableLine = false;
        DebugBlock = false;
        world.WorldInfo.isDebugMode = DebugBlock;
        DeleteSpriteTag = !DeleteSpriteTag;
        UpdateBtns();
    }

    public void OnClick_OpenBlockRect()
    {
        DebugBlock = false;
        world.WorldInfo.isDebugMode = DebugBlock;
        EnableLine = false;
        OpenBlockRect = !OpenBlockRect;
        if (OpenBlockRect)
        {
            //world.WorldInfo.BoxDrawer.Show();
            Shader.EnableKeyword("_BORDER_ON");
            Shader.DisableKeyword("_BORDER_OFF");
        }
        else
        {
            //world.WorldInfo.BoxDrawer.Hide();
            Shader.DisableKeyword("_BORDER_ON");
            Shader.EnableKeyword("_BORDER_OFF");
        }
        UpdateBtns();
    }

    public void OnClick_Occupy()
    {
        EnableLine = false;
        DebugBlock = false;
        world.WorldInfo.isDebugMode = DebugBlock;
        Occupy = !Occupy;
        UpdateBtns();
    }

    public void OnClick_DebugBlock()
    {
        DebugBlock = !DebugBlock;

        world.WorldInfo.isDebugMode = DebugBlock;
        if (DebugBlock)
        {
            //world.WorldInfo.BoxDrawer.Show();
            Shader.EnableKeyword("_BORDER_ON");
            Shader.DisableKeyword("_BORDER_OFF");
        }
        else
        {
            //world.WorldInfo.BoxDrawer.Hide();
            Shader.DisableKeyword("_BORDER_ON");
            Shader.EnableKeyword("_BORDER_OFF");
        }

        DeleteSpriteTag = false;
        OpenBlockRect = false;
        Occupy = false;
        EnableLine = false;
        UpdateBtns();
    }
    private bool EnableDetal8 = true;
    private int mDetal = 0;
    public void OnClick_Detal()
    {
        EnableLine = false;
        switch(mDetal)
        {
            case 0:
                Shader.EnableKeyword("_DETal8");
                Shader.DisableKeyword("_DETal4");
                Shader.DisableKeyword("_DETal2");
                break;
            case 1:
                Shader.EnableKeyword("_DETal4");
                Shader.DisableKeyword("_DETal8");
                Shader.DisableKeyword("_DETal2");
                break;
            case 2:
                Shader.EnableKeyword("_DETal2");
                Shader.DisableKeyword("_DETal8");
                Shader.DisableKeyword("_DETal4");
                break;
        }
        mDetal ++;
        if(mDetal >= 3)
        {
            mDetal = 0;
        }
        UpdateBtns();
    }
    private bool EnableWaterRefl = true;
    public void OnClick_WaterRefl()
    {
        EnableLine = false;
        EnableWaterRefl = !EnableWaterRefl;
        if (EnableWaterRefl)
        {
            Shader.EnableKeyword("WATER_REFL_ON");
            Shader.DisableKeyword("WATER_REFL_OFF");
        }
        else
        {
            Shader.EnableKeyword("WATER_REFL_OFF");
            Shader.DisableKeyword("WATER_REFL_ON");
        }
        UpdateBtns();
    }
    private bool EnableWaterSpec = true;
    public void OnClick_WaterSpec()
    {
        EnableLine = false;
        EnableWaterSpec = !EnableWaterSpec;
        if (EnableWaterRefl)
        {
            Shader.EnableKeyword("WATER_SPEC_ON");
            Shader.DisableKeyword("WATER_SPEC_OFF");
        }
        else
        {
            Shader.EnableKeyword("WATER_SPEC_OFF");
            Shader.DisableKeyword("WATER_SPEC_ON");
        }
        UpdateBtns();
    }
    [System.NonSerialized]
    public bool EnableLine = false;

    public void OnClick_Line()
    {
        EnableLine = !EnableLine;
        UpdateBtns();
    }
}
