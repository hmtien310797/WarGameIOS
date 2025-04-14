// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//dabian
Shader "Custom/Cull Shape Colored"
{
	Properties
	{
		_MainTex ("Base (RGB), Alpha (A)", 2D) = "black" {}		
		_MaskColor ("Mask Color", Color) = (0,0.2,0.5,0.5)
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
			float4 _MaskColor;
			
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
				//fixed4 color : COLOR; 
				fixed gray : TEXCOORD1;
			}; 
	
			v2f vert (appdata_t v)
			{
				v2f o; 
				o.vertex = UnityObjectToClipPos(v.vertex); 
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex); 
				//o.color = _MaskColor; 
				o.gray = dot(v.color, fixed4(1,1,1,0));
				//o.a = v.a;
				return o; 
			}
				
			fixed4 frag (v2f IN) : COLOR
			{
				fixed4 col; 				
				if (IN.gray == 0)
				{ 
				    //col = tex2D(_MainTex, IN.texcoord);
					//fixed4 color = _MaskColor;
					col = tex2D(_MainTex, IN.texcoord); 
					col.rgb = _MaskColor.rgb; 
					if (col.a > _MaskColor.a)
						col.a = _MaskColor.a;
				} 
				else 
				{ 
					col.rgb = _MaskColor.rgb; 
					col.a = _MaskColor.a;
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
