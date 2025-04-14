using UnityEngine;
using System.Collections;

namespace Clishow
{
    public class CsQualityController : MonoBehaviour
    {
        public enum LevelDist
        {
            LOW = 0,
            MIDDLE = 1,
            HEIGHT = 2,
        }
        public LevelDist SupportMinLevel = 0;

        void Awake()
        {
            if(SupportMinLevel == LevelDist.LOW )
                return;
            bool enable = GameSetting.instance.option.mQualityLevel >= (int)SupportMinLevel;
            if(enable != this.gameObject.activeSelf)
                this.gameObject.SetActive(enable);
        }
    }
}

