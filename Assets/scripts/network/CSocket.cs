using UnityEngine;
using System.Collections;
using System.Net.Sockets;
using System.Net;
using System;
using System.Threading;

public class CSocket
{
	public enum SocketState
	{
    	StateInit,
    	StateConnecting,
    	StateConnected,
    	StateShutDown,
    	StateSocketError,
	};

	string	    mServerIp;
	int			mPort;
	
    Socket mSocket = null;

    SocketState mState;
	
    const int SEND_BUFFER_LEN = 131072;
    const int RECEIVE_BUFFER_LEN = 1310720;

    byte[] mSendBuffer = new byte[SEND_BUFFER_LEN];
    int mSendHead = 0;
    int mSendTail = 0;

    byte[] m_RecvBuffer = new byte[RECEIVE_BUFFER_LEN];
    int mRecvHead = 0;
    int mRecvTail = 0;

    bool mIsSending = false;
    bool mIsRecving = false;

	//error info
    //error code
    SocketError mErrorCode;

	bool 		mUseThread = false;

	Thread		mConnectThread = null;
	bool 		mClearConnectThread = false;

	Thread		mSendThread = null;
	bool		mKillSendThread = false;
	bool		mClearSendThread = false;

	Thread		mRecvThread = null;
	bool		mKillRecvThread = false;
	bool		mClearRecvThread = false;
	
	public CSocket()
	{
		mState = SocketState.StateInit;
		ClearSocketErrorCode();
	}

	public SocketError SocketErrorCode
    {
		get
		{
			SocketError code = mErrorCode;
			ClearSocketErrorCode();
			return code; 
		}
    }
	
	public bool IsErrorState()
    {
        return mState == SocketState.StateSocketError;
    }
	
	public bool IsSending()
	{
		return mIsSending;
	}
	
	public bool IsRecving()
	{
		return mIsRecving;
	}
	
	public int GetRecvDataSize()
	{
		return mRecvTail - mRecvHead;
	}
	
    public int GetRecvBuffTail()
    {
        return mRecvTail;
    }


    public int GetRecvBuffHead()
    {
        return mRecvHead;
    }

    private void SetErrorState(SocketError errcode)
	{
		if(!IsErrorState())
        {
            mState = SocketState.StateSocketError;
            mErrorCode = errcode;
        }
	}
	
    private void ClearSocketErrorCode()
    {
		mErrorCode = System.Net.Sockets.SocketError.Success;
    }
	
    public SocketState state
    {
        get
		{
			return mState;
		}
    }

	void ConnectWithThread()
	{
		Thread.Sleep(0);
		
		if (mSocket != null)
		{
			try
			{
				mSocket.Connect(mServerIp, mPort);
				mState = SocketState.StateConnected;
			}
			catch (System.Net.Sockets.SocketException ex)
			{
				SetErrorState(ex.SocketErrorCode);
			}
		}

		mClearConnectThread = true;
	}


	public void ConnectSocket(string server, string port)
	{
        AddressFamily mIPType = AddressFamily.InterNetwork;
        mServerIp = server;
        mPort = int.Parse(port);

        try
        {
            string mIpv6 = WSdkManager.instance.GetIpv6(server, port);
            if (!string.IsNullOrEmpty(mIpv6))
            {
                string[] strTemp = System.Text.RegularExpressions.Regex.Split(mIpv6, "&&");

                if (strTemp != null && strTemp.Length >= 2)
                {
                    string ipType = strTemp[1];

                    if (ipType == "ipv6")
                    {
                        mServerIp = strTemp[0];
                        mIPType = AddressFamily.InterNetworkV6;
                    }
                }
            }
        }
        catch(Exception e)
        {
            Serclimax.DebugUtils.LogError("GetIPV6 Error:" + e);
        }

        try
		{
            mSocket = new Socket(mIPType, SocketType.Stream, ProtocolType.Tcp);
            mSocket.NoDelay = true;

            mSendHead = mSendTail = 0;
			mRecvHead = mRecvTail = 0;
			mIsSending = mIsRecving = false;
			mState = SocketState.StateConnecting;
			ClearSocketErrorCode();

			if (!mUseThread)
			{
				mSocket.BeginConnect(mServerIp, mPort, new AsyncCallback(OnConnectComplete), null);
			}
			else
			{
				if (mConnectThread == null)
				{
					mConnectThread = new Thread(ConnectWithThread);
					mConnectThread.Start();
				}
			}
		}
        catch (System.Net.Sockets.SocketException ex)
        {
            SetErrorState(ex.SocketErrorCode);
        }		
	}
	
	public void Disconnect()
	{
		if (mSocket.Connected)
		{
			mSocket.Close();
		}

		mKillSendThread = true;
		mKillRecvThread = true;
	}

	void SendWithThread()
	{
		Thread.Sleep(0);
		
		while (!mKillSendThread)
		{
			try
			{
				if (null != mSocket && mSendHead != mSendTail && !mIsSending)
				{
					mIsSending = true;
					int iRet = mSocket.Send(mSendBuffer, mSendHead, mSendTail - mSendHead, SocketFlags.None);
					mIsSending = false;
					mSendHead += iRet;

                    var networkManager = NetworkManager.instance;
                    if (networkManager.enableLog)
                    {
                        networkManager.lastSendBytes = iRet;
                        networkManager.totalSendBytes += iRet;
                        Debug.LogWarningFormat("last send bytes:{0:N0}", iRet);
                    }
                }
				else
				{
					Thread.Sleep(200);	
				}
			}
			catch (System.Net.Sockets.SocketException ex)
			{
				Serclimax.DebugUtils.LogError("Send:" + ex.Message);
				SetErrorState(ex.SocketErrorCode);
			}
		}

		mKillSendThread = false;
		mClearSendThread = true;
	}

	void RecvWithThread()
	{
		Thread.Sleep(0);
		
		while (!mKillRecvThread)
		{
			try
			{
				if (null != mSocket && !mIsRecving)
				{
					mIsRecving = true;

					if (RECEIVE_BUFFER_LEN == mRecvTail)
					{
						System.Buffer.BlockCopy(m_RecvBuffer, mRecvHead, m_RecvBuffer, 0, mRecvTail - mRecvHead);
						mRecvTail -= mRecvHead;
						mRecvHead = 0;
					}
					
					if (RECEIVE_BUFFER_LEN == mRecvTail)
					{
						throw new Exception("recieve buffer is full");
					}

					int iRet = mSocket.Receive(m_RecvBuffer, mRecvTail, RECEIVE_BUFFER_LEN - mRecvTail, SocketFlags.None);
					if (iRet < 0)
					{
						Thread.Sleep(200);
					}
					else if (iRet == 0)
					{
						Serclimax.DebugUtils.LogError("Recv Error:Shutdown iRet:" + iRet);
						SetErrorState(SocketError.Shutdown);
					}
					else
					{
						mRecvTail += iRet;

                        var networkManager = NetworkManager.instance;
                        if (networkManager.enableLog)
                        {
                            networkManager.lastReceiveBytes = iRet;
                            networkManager.totalReceiveBytes += iRet;
                            Debug.LogWarningFormat("last receive bytes:{0:N0}", iRet);
                        }
                    }
					
					mIsRecving = false;
				}
			}
			catch (System.Net.Sockets.SocketException ex)
			{
				SetErrorState(ex.SocketErrorCode);
			}
		}

		mKillRecvThread = false;
		mClearRecvThread = true;
	}
	
	public void Update()
	{
		if (mState == SocketState.StateConnected)
		{
			if (!mUseThread) 
			{
				ProcessSend();
				ProcessRecv();
			}
			else
			{
				if (mSendThread == null)
				{
					mSendThread = new Thread(SendWithThread);
					mSendThread.Start();
				}

				if (mRecvThread == null)
				{
					mRecvThread = new Thread(RecvWithThread);
					mRecvThread.Start();
				}
			}
		}


		if (mClearConnectThread) 
		{
			mConnectThread = null;
			mClearConnectThread = false;		
		}

		if (mClearSendThread) 
		{
			mSendThread = null;
			mClearSendThread = false;				
		}

		if (mClearRecvThread) 
		{
			mRecvThread = null;
			mClearRecvThread = false;	
		}
	}
	
	private void ProcessSend()
    {
        try
        {
            if (null != mSocket && mSendHead != mSendTail && !mIsSending)
            {
				mIsSending = true;
                mSocket.BeginSend(mSendBuffer, mSendHead, mSendTail - mSendHead, 0, new AsyncCallback(SendCallBack), 0);
            }
        }
        catch (System.Net.Sockets.SocketException ex)
        {
            SetErrorState(ex.SocketErrorCode);
        }
    }
	
    private void ProcessRecv()
    {
        try
        {
            if (null != mSocket && !mIsRecving)
            {
                mIsRecving = true;

                if (RECEIVE_BUFFER_LEN == mRecvTail)
                {
                    System.Buffer.BlockCopy(m_RecvBuffer, mRecvHead, m_RecvBuffer, 0, mRecvTail - mRecvHead);
                    mRecvTail -= mRecvHead;
                    mRecvHead = 0;
                }

                if (RECEIVE_BUFFER_LEN == mRecvTail)
                {
					throw new Exception("recieve buffer is full");
                }
                mSocket.BeginReceive(m_RecvBuffer, mRecvTail, RECEIVE_BUFFER_LEN - mRecvTail, 0, new AsyncCallback(RecvCallBack), 0);
            }
        }
        catch (System.Net.Sockets.SocketException ex)
        {
            SetErrorState(ex.SocketErrorCode);
        }
    }	
	
	private void RecvCallBack(IAsyncResult ar)
	{
        var networkManager = NetworkManager.instance;
        float analogDelay = networkManager.analogDelay;
        if (analogDelay > 0 && networkManager.GetMsgStackCount() > 0)
        {
            Thread.Sleep((int)(analogDelay * 1000));
        }

        try
        {
            if (null != mSocket)
            {
                int iRead = mSocket.EndReceive(ar);
                mRecvTail += iRead;
                mIsRecving = false;
                //msdn If the remote host shuts down the Socket connection with the Shutdown method, 
				//and all available data has been received, the EndReceive method will complete immediately and return zero bytes.
                if (iRead == 0)
                {
                    SetErrorState(SocketError.Shutdown);
                }

                if (networkManager.enableLog)
                {
                    networkManager.lastReceiveBytes = iRead;
                    networkManager.totalReceiveBytes += iRead;
                    Debug.LogWarningFormat("last receive bytes:{0:N0}", iRead);
                }
            }
        }
        catch (System.Net.Sockets.SocketException ex)
        {
            SetErrorState(ex.SocketErrorCode);
        }		
	}
	
	private void SendCallBack(IAsyncResult ar)
	{
        try
        {
            if (null != mSocket)
            {
                int iSize = mSocket.EndSend(ar);
                mSendHead += iSize;
                mIsSending = false;

                var networkManager = NetworkManager.instance;
                if (networkManager.enableLog)
                {
                    networkManager.lastSendBytes = iSize;
                    networkManager.totalSendBytes += iSize;
                    Debug.LogWarningFormat("last send bytes:{0:N0}", iSize);
                }
            }
        }
        catch (System.Net.Sockets.SocketException ex)
        {
            SetErrorState(ex.SocketErrorCode);
        }		
	}
	
	private void OnConnectComplete(IAsyncResult ar)
	{
		try
        {
            if (null != mSocket)
            {
                mSocket.EndConnect(ar);
                mState = SocketState.StateConnected;
            }
        }
        catch (System.Net.Sockets.SocketException ex)
        {
            SetErrorState(ex.SocketErrorCode);
        }
	}
	
	public int Send(byte[] buf, int iOffset, int size)
    {
        if (mSendTail + size > SEND_BUFFER_LEN)
        {
            System.Buffer.BlockCopy(mSendBuffer, mSendHead, mSendBuffer, 0, mSendTail - mSendHead);
            mSendTail -= mSendHead;
            mSendHead = 0;
        }

        if (mSendTail + size > SEND_BUFFER_LEN)
        {
            throw new Exception("Send Buffer full Exception");
        }

        System.Buffer.BlockCopy(buf, iOffset, mSendBuffer, mSendTail, size);
        mSendTail += size;

        if (!mUseThread)
            ProcessSend();

        return size;
    }
	
    public int Recv(byte[] buf, int iOffset, int size)
    {
        int iReadSize = Math.Min(size, mRecvTail - mRecvHead);

        if(iReadSize != 0)
        {
            System.Buffer.BlockCopy(m_RecvBuffer, mRecvHead, buf, iOffset, iReadSize);
            mRecvHead +=  iReadSize;
        }
        return iReadSize;
    }

    public void Reset()
    {
        mRecvHead = 0;
        mRecvTail = 0;
    }
}