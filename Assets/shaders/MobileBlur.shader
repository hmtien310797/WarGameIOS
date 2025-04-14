// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "Hidden/MobileBlur" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}
	
	CGINCLUDE

		#include "UnityCG.cginc"

		sampler2D _MainTex;
	
		uniform half4 _MainTex_TexelSize;

		struct v2f_simple {
			half4 pos : SV_POSITION;
			half4 uv : TEXCOORD0;
		};
				
		struct v2f_withBlurCoords {
			half4 pos : SV_POSITION;
			half2 uv2[4] : TEXCOORD0;
		};	
		
		v2f_withBlurCoords vertBlur (appdata_img v)
		{
			v2f_withBlurCoords o;
			o.pos = UnityObjectToClipPos (v.vertex);
			half offx1 = _MainTex_TexelSize.x * 1.5;
			half offx2 = _MainTex_TexelSize.x * 0.5;
			half offy = _MainTex_TexelSize.y * 0.5;
			o.uv2[0] = v.texcoord + half4(-offx1, 0, 0, 1);					
			o.uv2[1] = v.texcoord + half4(offx1, 0, 0, 1);
			o.uv2[2] = v.texcoord + half4(-offx2, -offy, 0, 1);
			o.uv2[3] = v.texcoord + half4(offx2, offy, 0, 1);
			return o; 
		}	

		v2f_withBlurCoords vertBlurVertical (appdata_img v)
		{
			v2f_withBlurCoords o;
			o.pos = UnityObjectToClipPos (v.vertex);
        	o.uv2[0] = v.texcoord + _MainTex_TexelSize.xy * half2(0.0, -1.5);			
			o.uv2[1] = v.texcoord + _MainTex_TexelSize.xy * half2(0.0, -0.5);	
			o.uv2[2] = v.texcoord + _MainTex_TexelSize.xy * half2(0.0, 0.5);	
			o.uv2[3] = v.texcoord + _MainTex_TexelSize.xy * half2(0.0, 1.5);	
			return o; 
		}	

		v2f_withBlurCoords vertBlurHorizontal (appdata_img v)
		{
			v2f_withBlurCoords o;
			o.pos = UnityObjectToClipPos (v.vertex);
        	o.uv2[0] = v.texcoord + _MainTex_TexelSize.xy * half2(-1.5, 0.0);			
			o.uv2[1] = v.texcoord + _MainTex_TexelSize.xy * half2(-0.5, 0.0);	
			o.uv2[2] = v.texcoord + _MainTex_TexelSize.xy * half2(0.5, 0.0);	
			o.uv2[3] = v.texcoord + _MainTex_TexelSize.xy * half2(1.5, 0.0);	
			return o; 
		}	
		
		fixed4 fragBlurForFlares ( v2f_withBlurCoords i ) : COLOR
		{				
			fixed4 color = tex2D (_MainTex, i.uv2[0]);
			color += tex2D (_MainTex, i.uv2[1]);
			color += tex2D (_MainTex, i.uv2[2]);
			color += tex2D (_MainTex, i.uv2[3]);
			return color * 0.25;
		}
			
	ENDCG
	
	SubShader {
	  ZTest Always Cull Off ZWrite Off Blend Off
	  Fog { Mode off }  
	  
	// 0
	Pass {
		CGPROGRAM
		
		#pragma vertex vertBlurVertical
		#pragma fragment fragBlurForFlares
		#pragma fragmentoption ARB_precision_hint_fastest 
		
		ENDCG 
		}	
	// 1			
	Pass {
		CGPROGRAM
		
		#pragma vertex vertBlurHorizontal
		#pragma fragment fragBlurForFlares
		#pragma fragmentoption ARB_precision_hint_fastest 
		
		ENDCG
		}
	// 2			
	Pass {
		CGPROGRAM
		
		#pragma vertex vertBlur
		#pragma fragment fragBlurForFlares
		#pragma fragmentoption ARB_precision_hint_fastest
		
		ENDCG
		}	
	}
	FallBack Off
}
