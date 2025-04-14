using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class XTableData
{
	static XTableData sInstance;
	
	public static XTableData instance
	{
		get
		{
			if (sInstance == null)
			{
				sInstance = new XTableData();
			}
			return sInstance;
		}
	}

	

}
