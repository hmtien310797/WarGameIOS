using UnityEngine;
using System.Collections;

namespace Clishow
{
    public class CsUnitAttr
    {
        private int teamId;

        private int hp;

        private int maxHP;

        public int TeamId
        {
            get
            {
                return teamId;
            }

            set
            {
                teamId = value;
            }
        }

        public int HP
        {
            get
            {
                return hp;
            }

            set
            {
                hp = value;
            }
        }

        public int MaxHP
        {
            get
            {
                return maxHP;
            }

            set
            {
                maxHP = value;
            }
        }
    }
}
