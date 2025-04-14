using UnityEngine;
using System.Collections;
using System;

public class MapBuildEffect
{

    World world;
    int type;

    public void Init(World w)
    {
        world = w;
    }
    public void ClearView()
    {
        world.worldMapBuildEffect.ClearView(world.worldMapUpdata.CurRect);
    }

    public void UpdateBuildEffect(int x, int y, int lindex)
    {
        FastStack<int> effect = world.WorldInfo.WBlockMap.GetEffect(lindex);
        world.worldMapBuildEffect.GetEffectList(lindex);
        bool hadEffectData = effect != null && effect.Count != 0;
        bool buildHadEffect = world.worldMapBuildEffect.tmpEffectList != null && world.worldMapBuildEffect.tmpEffectList.Count != 0;

        if (!hadEffectData)
        {
            if (buildHadEffect)
            {
                world.worldMapBuildEffect.HideEffect(lindex);
            }
            else
            {
                return;
            }
        }
        else
        {
            world.worldMapBuildEffect.ShowEffect(x, y,lindex,effect);
        }
    }

    int DecodeEffect(int effect, int n)
    {
        return effect & (1 << n);
    }

    int GetStringToNumber(string type, int count)
    {
        count++;
        return int.Parse(type.Substring(type.Length - count, count));
    }


}
