// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "wgame/Scene/Transparent Alpha 0"
{
	Properties
	{
	}

	CGINCLUDE
		#include"UnityCG.cginc"
		struct appdata
		{
			float4 vertex : POSITION;
		};

		struct v2f
		{
			float4 pos : SV_POSITION;
		};

		v2f vert(appdata v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			return o;
		}


		fixed4 frag(v2f i) :SV_Target
		{
			return fixed4(0,0,0,0);
		}
	ENDCG


		SubShader
		{
			Tags{ "Queue" = "Transparent"  "RenderType" = "Transparent" }

			LOD 100
			Fog{ Mode Off }
			//Cull Off
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMask RGB
			Pass
			{
				Tags { "LightMode" = "Vertex" }
				CGPROGRAM
				#pragma vertex vert  
				#pragma fragment frag
				ENDCG
			}
		}
		//Fallback "Diffuse"
}