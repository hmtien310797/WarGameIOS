using UnityEngine;
using System.Collections;
using Clishow;

namespace Clishow
{
    public class CsUnitAttrSyncer : CsSynchronizer<Serclimax.Unit.ScUnitMsg>
    {
        private CsUnitAttr unitAttr;
        private CsUnit mUnit;
        public CsUnitAttrSyncer(CsUnitAttr unitAttr , CsUnit unit)
        {
            this.unitAttr = unitAttr;
            mUnit = unit;
        }

        public override void Sync(Serclimax.Unit.ScUnitMsg msg)
        {
            unitAttr.TeamId = msg.TeamId;
            unitAttr.HP = (int)msg.HP;
            unitAttr.MaxHP = (int)msg.maxHP;
        }

        public override void Update(float dt)
        {

        }
    }
}