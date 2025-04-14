using System;
using System.Collections.Generic;
using UnityEngine;

namespace Clishow
{
    public class CsLockStepSynchronizer
    {
        public struct TurnInfo
        {
            public UInt64 Pretime;

            public UInt64 TargetTime;

            public int StartFrame;

            public int EndFrame;
            public TurnInfo(UInt64 pre_time, UInt64 target_time,int length, UInt64 startTime)
            {
                Pretime = pre_time;
                TargetTime = target_time;
                StartFrame = (Convert.ToInt32(Pretime - startTime) )/ length;
                EndFrame = (Convert.ToInt32(TargetTime - startTime))/ length;
            }
        }

        private static TurnInfo InvaildTurnInfo = new TurnInfo(0, 0, 1,0);

        public delegate void DisposeMsgCallback(UInt64 time);

        public delegate void GameUpdateCallback(float dt);

        private int mFrameTurnLength = 50;

        private int mAccumilatedTime = 0;

        private UInt64 mPreTurnTime = 0;

        private UInt64 mTargetTurnTime = 0;

        private int mCurFrame = 0;

        private int mTargetFrame = 0;

        private int mRunFrame = 0;

        private bool mEnable = false;

        private UInt64 mTurnSerStartTime = 0;

        private DisposeMsgCallback mDisposeMsgCB = null;

        private GameUpdateCallback mGameUpdateCB = null;

        private List<TurnInfo> mCacheTurns = new List<TurnInfo>();

        private TurnInfo mCurTurn;
        public int RunFrame
        {
            get
            {
                return mRunFrame;
            }
        }

        public void Stop()
        {
            mCurTurn = InvaildTurnInfo;
            mCacheTurns.Clear();
            mGameUpdateCB = null;
            mDisposeMsgCB = null;
            mAccumilatedTime = 0;
            mPreTurnTime = 0;
            mTargetTurnTime = 0;
            mTurnSerStartTime = 0;
            mEnable = false;
        }

        public void Start(DisposeMsgCallback dispose_msg, GameUpdateCallback game_update)
        {
            Stop();
            mGameUpdateCB = game_update;
            mDisposeMsgCB = dispose_msg;
        }

        public void SyncTime(UInt64 pre_time, UInt64 target_time)
        {

            mCacheTurns.Add(new TurnInfo(pre_time, target_time, mFrameTurnLength, mTurnSerStartTime==0? pre_time: mTurnSerStartTime));
            if (!mEnable)
            {
                mTurnSerStartTime = pre_time;
                mEnable = true;
                mRunFrame = 0;
                GetVaildTurn();
            }
        }
        public void Update()
        {
            mAccumilatedTime = mAccumilatedTime + Convert.ToInt32((Time.deltaTime * 1000));
            
            while (mAccumilatedTime > mFrameTurnLength)
            {
                GameFrameTurn();
                mAccumilatedTime = mAccumilatedTime - mFrameTurnLength;
            }
        }

        private void DoGameUpdate(float dt)
        {
            if (mGameUpdateCB != null)
            {
                mGameUpdateCB(dt);
            }
            if(mEnable)
                mRunFrame++;
        }


        private bool GetVaildTurn()
        {
            if (mCacheTurns.Count == 0)
                return false;
            for (int i = 0; i < mCacheTurns.Count;)
            {
                mCurTurn = mCacheTurns[i];
                if (mRunFrame < mCurTurn.EndFrame)
                {
                    if (mDisposeMsgCB != null)
                    {
                        mDisposeMsgCB(mCurTurn.Pretime);
                    }
                    return true;
                }
                else
                {
                    mCacheTurns.RemoveAt(i);
                }
            }
            return false;
        }
        private void GameFrameTurn()
        {
            if (!mEnable)
            {
                DoGameUpdate(Time.deltaTime);
                return;
            }
            float dt = (float)mFrameTurnLength / (float)1000;
            if (mRunFrame >= mCurTurn.EndFrame)
            {
                if (!GetVaildTurn())
                    return;
            }

            int cacheCount = mCacheTurns.Count;
            if (cacheCount <= 25)
            {
                DoGameUpdate(dt);
            }
            else
            if (cacheCount > 25 && cacheCount < 50)
            {
                for (int i = 0, imax = 5; i < imax; i++)
                {

                    if (mRunFrame >= mCurTurn.EndFrame)
                    {
                        if (GetVaildTurn())
                            DoGameUpdate(dt);
                        else
                            break;
                    }
                    else
                        DoGameUpdate(dt);
                }
            }
            //else
            //{
            //    bool update = true;
            //    while (update)
            //    {
            //        if (mRunFrame >= mCurTurn.EndFrame)
            //        {
            //            if (GetVaildTurn())
            //                DoGameUpdate(dt);
            //            else
            //                update = false;
            //        }
            //        else
            //            DoGameUpdate(dt);

            //        if (mCacheTurns.Count == 0)
            //            update = false;
            //    }

            //}
        }

    }
}
