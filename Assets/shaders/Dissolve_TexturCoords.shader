// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Rhino/Dissolve_TexturCoords" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Color ("Main Color", Color) = (1,1,1,1)
		_Shininess ("Shininess", Range (0.03, 1)) = 0.078125
		_Amount ("Amount", Range (0, 1)) = 0.5
		_StartAmount("StartAmount", float) = 0.1
		_Illuminate ("Illuminate", Range (0, 1)) = 0.5
		_Tile("Tile", float) = 1
		_DissColor ("DissColor", Color) = (1,1,1,1)
		_ColorAnimate ("ColorAnimate", vector) = (1,1,1,1)
		_DissolveSrc ("DissolveSrc", 2D) = "white" {}
	}

	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		Pass {  
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				
				#include "UnityCG.cginc"
			    
			    
			    half4 _DissColor;
				half _Shininess;
				half _Amount;
				static half3 Color = float3(1,1,1);
				half4 _ColorAnimate;
				half _Illuminate;
				half _Tile;
				half _StartAmount;
				fixed4 _Color;
				sampler2D _DissolveSrc;
		
			    
				struct appdata_t {
					float4 vertex : POSITION;
					float2 texcoord : TEXCOORD0;
				};
				
				
				struct v2f {
					float4 vertex : SV_POSITION;
					half2 texcoord : TEXCOORD0;
				};

				sampler2D _MainTex;
				float4 _MainTex_ST;

				v2f vert (appdata_t v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
					return o;
				}
				
				fixed4 frag (v2f i) : SV_Target
				{
					fixed4 tex = tex2D(_MainTex, i.texcoord);
					fixed3 col=tex.rgb;
				    float ClipTex = tex2D (_DissolveSrc, i.texcoord).r ;
					float ClipAmount = ClipTex - _Amount;
					float Clip = 0;
					
					if (_Amount > 0)
					{
						if (ClipAmount <0)
						{
							Clip = 1; //clip(-0.1);
						
						}
						 else
						 {
						
							if (ClipAmount < _StartAmount)
							{
								if (_ColorAnimate.x == 0)
									Color.x = _DissColor.x;
								else
									Color.x = ClipAmount/_StartAmount;
					          
								if (_ColorAnimate.y == 0)
									Color.y = _DissColor.y;
								else
									Color.y = ClipAmount/_StartAmount;
					          
								if (_ColorAnimate.z == 0)
									Color.z = _DissColor.z;
								else
									Color.z = ClipAmount/_StartAmount;

								col  = (col *((Color.x+Color.y+Color.z))* Color*((Color.x+Color.y+Color.z)))/(1 - _Illuminate);
							}
						 }
					 }

	 
					if (Clip == 1)
					{
						clip(-0.1);
					}

					fixed4 c;
					c.rgb=col;
					c.a=tex.a*_Color.a;
					UNITY_OPAQUE_ALPHA(c.a);
					return c;
				}
			ENDCG
		}
	}

}
