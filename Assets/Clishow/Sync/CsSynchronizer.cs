using System;
using System.Collections.Generic;
using UnityEngine;
namespace Clishow
{
    public class CsSynchronizer<T> where T:Serclimax.IScMsgBase
    {
        public virtual void Sync(T msg)
        { }

        public virtual void Update(float _dt)
        {
        }

        public virtual void OnDestroy()
        {
        }

        public virtual void OnReset()
        {

        }

        public virtual void Command(string cmd)
        {

        }
    }

    public class CsSyncontroller<T> where T : Serclimax.IScMsgBase
    {
        private List<CsSynchronizer<T>> mSyncers = new List<CsSynchronizer<T>>();

        public void AddSyncer(CsSynchronizer<T> syncer)
        {
            mSyncers.Add(syncer);
        }

        public void SyncMsg(T msg)
        {
            for (int i = 0, imax = mSyncers.Count; i < imax; i++)
            {
                mSyncers[i].Sync(msg);
            }
        }

        public void UpdateSync(float _dt)
        {
            for (int i = 0, imax = mSyncers.Count; i < imax; i++)
            {
                mSyncers[i].Update(_dt);
            }
        }

        public void OnDestroy()
        {
            for (int i = 0, imax = mSyncers.Count; i < imax; i++)
            {
                mSyncers[i].OnDestroy();
            }
        }

        public void OnReset()
        {
            for (int i = 0, imax = mSyncers.Count; i < imax; i++)
            {
                mSyncers[i].OnReset();
            }
        }

        public void Command(string cmd)
        {
            for (int i = 0, imax = mSyncers.Count; i < imax; i++)
            {
                mSyncers[i].Command(cmd);
            }
        }

        public void Clear()
        {
            mSyncers.Clear();
        }
    }
}
