using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.InteropServices;
using System.Diagnostics;
using System.Net;

/// <summary>
/// 网络封包包头
/// </summary>
[StructLayout(LayoutKind.Sequential, Pack = 1)]
public struct PackageHead
{
    /// <summary>
    /// 有效负载的类型
    /// </summary>
    public PackageHeadFlags Flags;
    public byte EncryptPaddingSize;
    /// <summary>
    /// 随后附带的有效负载字节长度
    /// </summary>
    public ushort MessageLength;


    private readonly static int s_size;
    /// <summary>
    /// 包头的字节大小
    /// </summary>
    public static int SizeOf { get { return s_size; } }

    static PackageHead()
    {
        s_size = GetStructSize<PackageHead>();
    }

    private static int GetStructSize<T>() where T : struct
    {
        return Marshal.SizeOf<T>();
    }


    public void WriteTo(System.IO.Stream stream)
    {
        byte[] buf = new byte[SizeOf];
        WriteTo(buf, 0);
        stream.Write(buf, 0, buf.Length);
    }

    public void WriteTo(byte[] buf, int index)
    {
        CheckBuf(buf, index);
        var length = BitConverter.GetBytes(this.MessageLength);
        buf[index + 2] = (byte)this.EncryptPaddingSize;
        buf[index + 3] = (byte)this.Flags;
        length.CopyTo(buf, index);
    }


    public void ReadFrom(byte[] buf, int offset)
    {
        // 大端数据
        CheckBuf(buf, offset);
        //Console.WriteLine("-消息头={0}-{1}-{2}-{3}-", buf[0], buf[1], buf[2], buf[3]);
        this.Flags = (PackageHeadFlags)buf[offset + 3];
        this.EncryptPaddingSize = (byte)buf[offset + 2];
        this.MessageLength = BitConverter.ToUInt16(buf, offset);
        // Console.WriteLine("-消息头=Flag=0x{0:X4},MessageLength={1}-", (uint)Flags, (int)MessageLength);
    }

    private static void CheckBuf(byte[] buf, int index)
    {
        if (buf == null)
            throw new ArgumentNullException("buf");
        if (index < 0 || index + SizeOf > buf.Length)
            throw new ArgumentOutOfRangeException("index");
    }

    public override string ToString()
    {
        return string.Format("{{Flag=0x{0:X4},MessageLength={1}}}", Flags, MessageLength);
    }
}
