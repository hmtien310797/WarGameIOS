using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using Serclimax;
using System;

namespace Clishow
{
    public class CsDisDaCenter : CsSingletonBehaviour<CsDisDaCenter>
    {
        private Serclimax.ScDisDaCenter mCenter = null;

        public override bool IsAutoInit()
        {
            return true;
        }

        public override bool IsGlobal()
        {
            return false;
        }
        public override void Initialize(object param = null)
        {
            if (mInitialized)
                return;
            mCenter = new ScDisDaCenter();
            mValid = true;
            mInitialized = true; 
        }

        public override void OnDestroy()
        {
            base.OnDestroy();
            mCenter.Clear();
            mCenter = null;
        }

        public Serclimax.ScDisDaCenter DisCenter
        {
            get
            {
                return mCenter;
            }
        }

    }
}


