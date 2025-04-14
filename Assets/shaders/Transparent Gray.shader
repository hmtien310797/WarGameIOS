// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Transparent Gray" {
	Properties
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB), Alpha (A)", 2D) = "black" {}
	}
	
	SubShader
	{
		LOD 200

		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}
		
		Pass
		{
			//Cull Off
			Lighting Off
			ZWrite Off
			Fog { Mode Off }
			Offset -1, -1
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag			
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			int _isGray;
			fixed4 _Color;
	
			struct appdata_t
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};
	
			struct v2f 
			{ 
				float4 vertex : SV_POSITION; 
				half2 texcoord : TEXCOORD0; 
			}; 
	
			v2f vert (appdata_t v)
			{
				v2f o; 
				o.vertex = UnityObjectToClipPos(v.vertex); 
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex); 
				return o; 
			}
				
			fixed4 frag (v2f IN) : COLOR
			{
				fixed4 col; 
				if (_isGray == 1)
				{ 
					col = tex2D(_MainTex, IN.texcoord); 
					col.rgb = dot(col.rgb, fixed3(.1,.1,.1));					
				} 
				else 
				{ 
					col = tex2D(_MainTex, IN.texcoord) * _Color; 
				} 
				return col; 
			}
			ENDCG
		}
	}
}
