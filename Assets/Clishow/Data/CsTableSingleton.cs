using System;
using System.Collections.Generic;
using UnityEngine;

namespace Clishow
{
    public class CsTableSingleton : CsSingletonBehaviour<CsTableSingleton>
    {
        private Serclimax.ScTableMgr mTables = null;

        public override bool IsAutoInit()
        {
            return false; 
        }

        public override bool IsGlobal()
        {
            return true;
        }

        public Serclimax.ScTableMgr Tables
        {
            get
            {
                return mTables;
            }
        }

        public override void Initialize( object param = null)
        {
            if (mInitialized)
                return;
            mTables = new Serclimax.ScTableMgr();
            mTables.Init();
            mValid = true;
            mInitialized = true;
        }
    }
}
