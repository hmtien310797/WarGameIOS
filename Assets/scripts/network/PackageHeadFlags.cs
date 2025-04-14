using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

[Flags]
public enum PackageHeadFlags : byte
{
    Partial = 0x01,  // 包不完全标志，即实际包长 > ushort.MaxValue需要拆包发送
    Zip = 0x40,		// 压缩标示
}
