// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "FX/Multiply" {
	Properties {
		_MainTex ("Base", 2D) = "white" {}
	}
	
	CGINCLUDE

		#include "UnityCG.cginc"

		sampler2D _MainTex;
		
		struct appdata_t {
			float4 vertex : POSITION;
			fixed4 color : COLOR;
			float2 texcoord : TEXCOORD0;
		};	
					
		struct v2f {
			half4 pos : SV_POSITION;
			half2 uv : TEXCOORD0;
			fixed4 color : COLOR;
		};

		v2f vert(appdata_t v) {
			v2f o;
			
			o.pos = UnityObjectToClipPos (v.vertex);	
			o.uv.xy = v.texcoord.xy;
			o.color = v.color;
					
			return o; 
		}
		
		fixed4 frag( v2f i ) : COLOR {	
			return tex2D (_MainTex, i.uv.xy) * i.color;
		}
	
	ENDCG
	
	SubShader {
		Tags { "RenderType" = "Transparent" "IgnoreProjector"="True" "Queue" = "Transparent" }
		Cull Off
		Lighting Off
		ZWrite Off
		Fog { Mode Off }
		Blend Zero SrcColor
		
	Pass {
	
		CGPROGRAM
		
		#pragma vertex vert
		#pragma fragment frag
		#pragma fragmentoption ARB_precision_hint_fastest 
		
		ENDCG
		 
		}
				
	} 
	FallBack Off
}
