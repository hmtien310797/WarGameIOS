// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/EquipGray"
{
	Properties
	{
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
	
			struct appdata_t
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				fixed4 color : COLOR;
			};
	
			struct v2f 
			{ 
				float4 vertex : SV_POSITION; 
				half2 texcoord : TEXCOORD0; 
				fixed4 color : COLOR; 
				fixed gray : TEXCOORD1;
			}; 
	
			v2f vert (appdata_t v)
			{
				v2f o; 
				o.vertex = UnityObjectToClipPos(v.vertex); 
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex); 
				o.color = v.color; 
				o.gray = dot(v.color, fixed4(1,1,1,0));
				return o; 
			}
				
			fixed4 frag (v2f IN) : COLOR
			{
				fixed4 col; 
				if (IN.gray == 0)
				{ 
					col = tex2D(_MainTex, IN.texcoord); 
					float c = (col.r+col.g+col.b)/3;
					c = 0.6+c*0.6;
					col.r = col.g = col.b = c;
					col *= fixed4(.371,.371,.571,1);
				} 
				else 
				{ 
					col = tex2D(_MainTex, IN.texcoord) * IN.color; 
				} 
				return col; 
			}
			ENDCG
		}
	}

	/*SubShader
	{
		LOD 100

		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}
		
		Pass
		{
			Cull Off
			Lighting Off
			ZWrite Off
			Fog { Mode Off }
			Offset -1, -1
			ColorMask RGB
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMaterial AmbientAndDiffuse
			
			SetTexture [_MainTex]
			{
				Combine Texture * Primary
			}
		}
	}*/
}
