// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/Unlit/Transparent Colored ETC1 1"
{
	Properties
	{
		_MainTex ("Base (RGB)", 2D) = "black" {}
		_MainTex_A ("Alpha (A)", 2D) = "white" {}  
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
			Cull Off
			Lighting Off
			ZWrite Off
			Offset -1, -1
			Fog { Mode Off }
			ColorMask RGB
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			sampler2D _MainTex_A;
			float4 _ClipRange0 = float4(0.0, 0.0, 1.0, 1.0);
			float2 _ClipArgs0 = float2(1000.0, 1000.0);

			struct appdata_t
			{
				float4 vertex : POSITION;
				half4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : POSITION;
				half4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				float2 worldPos : TEXCOORD1;
			};

			v2f o;

			v2f vert (appdata_t v)
			{
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.texcoord = v.texcoord;
				o.worldPos = v.vertex.xy * _ClipRange0.zw + _ClipRange0.xy;
				return o;
			}

			half4 frag (v2f IN) : COLOR
			{
				// Softness factor
				float2 factor = (float2(1.0, 1.0) - abs(IN.worldPos)) * _ClipArgs0;
			
				// Sample the texture
				half4 col;
				col.rgb = tex2D(_MainTex, IN.texcoord).rgb;
				col.a = tex2D(_MainTex_A, IN.texcoord).b;
				if (IN.color.r < 0.001 && IN.color.g > 0.001 && IN.color.b > 0.001)    
                {    
                    float grey = dot(col.rgb, float3(0.299, 0.587, 0.114));    
                    col.rgb = float3(grey, grey, grey);    
                }    
                else   
                    col = col * IN.color;  
				col.a *= clamp( min(factor.x, factor.y), 0.0, 1.0);
				return col;
			}
			ENDCG
		}
	}
	
	SubShader
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
			ColorMask RGB
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMaterial AmbientAndDiffuse
			
			SetTexture [_MainTex]
			{
				Combine Texture * Primary
			}
		}
	}
}
