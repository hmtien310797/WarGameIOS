// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Toon/Dabian_Unit_Blocked" {
Properties {

		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_AdditiveColor ("Additive Color", Color) = (0,0,0,0)
		_Emission ("Emissive Color", Color) = (0,0,0,0)

		_RimColor ("Rim Color", Color) = (0,0.25,1,1)
		_InnerColor ("Inner Color", Color) = (0,0,0,0)
		_InnerColorPower ("Inner Color Power", Range(0.0,1.0)) = 0.5
		_RimPower ("Rim Power", Range(0.0,5.0)) = 4
		_AlphaPower ("Alpha Rim Power", Range(0.0,8.0)) = 1.5
		_AllPower ("All Power", Range(0.0, 10.0)) = 1.0

}
SubShader {
	
	Tags 
	{
		"Queue"="Transparent"
		"IgnoreProjector"="True"
		"RenderType"="Transparent"
	}
	  
	Lighting Off
	ZWrite off
	ZTest Always  	
	Fog { Mode Off }	  
	Cull Back
	
	Pass 
	{
	 	Blend SrcAlpha One
		SetTexture[_MainTex] 
		{
		}
	}
		  
	Pass
	{
		ColorMask RGBA		
		Blend One One
		
		CGPROGRAM
		#include "UnityCG.cginc"
		#pragma vertex vert
		#pragma fragment frag
		#pragma fragmentoption ARB_fog_exp2
		#pragma fragmentoption ARB_precision_hint_fastest
		
		float4 _RimColor;
		float _RimPower;
		float _AlphaPower;
		float _AlphaMin;
		float _InnerColorPower;
		float _AllPower;
		float4 _InnerColor;

		struct v2f {
			float4 pos : SV_POSITION;
			float2 uv_MainTex : TEXCOORD0;
			float3 normal : TEXCOORD1;
			float3 worldvertpos : TEXCOORD2;
		};
		v2f vert (appdata_base v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv_MainTex = v.texcoord;			
			o.normal = mul(half4(v.normal,1),unity_WorldToObject);
			o.worldvertpos = mul(unity_ObjectToWorld, v.vertex).xyz;//float4(WorldSpaceViewDir(v.vertex),1); 

			return o;
		}
		fixed4 frag (v2f IN) : COLOR
		{
			IN.normal = normalize(IN.normal);
			float3 viewdir = normalize(_WorldSpaceCameraPos-IN.worldvertpos);			 
			float4 color = _RimColor;			 
			half rim = 1.0 - saturate(dot (viewdir, IN.normal));			
			color.rgb = _RimColor.rgb * pow (rim, _RimPower)*_AllPower+(_InnerColor.rgb*2*_InnerColorPower); 
			return color;
		}
		ENDCG
		}
	}
Fallback "VertexLit"
}
