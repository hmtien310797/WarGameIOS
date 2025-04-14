// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Toon/Rim_add" {
Properties {

		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_AdditiveColor ("Additive Color", Color) = (0,0,0,1)
		_Emission ("Emissive Color", Color) = (0,0,0,0)

_RimColor ("Rim Color", Color) = (0.5,0.5,0.5,0.5)
_InnerColor ("Inner Color", Color) = (0.5,0.5,0.5,0.5)
_InnerColorPower ("Inner Color Power", Range(0.0,1.0)) = 0.5
_RimPower ("Rim Power", Range(0.0,5.0)) = 2.5
_AlphaPower ("Alpha Rim Power", Range(0.0,8.0)) = 4.0
_AllPower ("All Power", Range(0.0, 10.0)) = 1.0


}
SubShader {
	
	Tags { "RenderType"="Opaque" }

	UsePass "wgame/Scene/Diffuse/PLAYER"
	
	Pass
	{
		Tags { "Queue" = "Transparent" "RenderType" = "Transparent"}
		Cull Back
		ZWrite On
		ZTest LEqual
		ColorMask RGBA
		
		//Fog{
		//Mode Global
		//Density 0.5
		//}
		Blend SrcColor One
		
		CGPROGRAM
		#include "UnityCG.cginc"
		#pragma vertex vert
		#pragma fragment frag
		#pragma fragmentoption ARB_fog_exp2
		#pragma fragmentoption ARB_precision_hint_fastest
		//#pragma target 2.0
		//#pragma surface surf Lambert alpha
		//struct Input {
		//float2 uv_MainTex;
		//float3 viewDir;
		//INTERNAL_DATA
		//};
		float4 _RimColor;
		float _RimPower;
		float _AlphaPower;
		float _AlphaMin;
		float _InnerColorPower;
		float _AllPower;
		float4 _InnerColor;
		//sampler2D _MainTex;

		struct v2f {
			float4 pos : SV_POSITION;
			float2 uv_MainTex : TEXCOORD0;
			float3 normal : TEXCOORD1;
			float3 worldvertpos : TEXCOORD2;
		};
		v2f vert (appdata_base v)
		{
			v2f o;

			//float4 tangent = float4(1, 1, 1, 1);
			//V_CW_TransformPointAndNormal(v.vertex,v.normal, tangent);
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv_MainTex = v.texcoord;
			
			o.normal = mul(half4(v.normal,1),unity_WorldToObject);
			//o.worldnormal.w = 1;
			//o.normal = v.normal;
						
			o.worldvertpos = mul(unity_ObjectToWorld, v.vertex).xyz;//float4(WorldSpaceViewDir(v.vertex),1); 

			return o;
		}
		fixed4 frag (v2f IN) : COLOR
		{
			IN.normal = normalize(IN.normal);
			 float3 viewdir = normalize(_WorldSpaceCameraPos-IN.worldvertpos);
			 
			 float4 color = _RimColor;
			 
			 half rim = 1.0 - saturate(dot (viewdir, IN.normal));
 
			color.a = pow(rim, _AlphaPower)*_AllPower;
			
			color.rgb = _RimColor.rgb * pow (rim, _RimPower)*_AllPower+(_InnerColor.rgb*2*_InnerColorPower);
 
			//color.a *= dot(normalize(IN.worldvertpos-_WorldSpaceLightPos0), IN.normal);
 
			return color;
 

			//fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
				//o.Albedo = c.rgb ;
			//half rim = 1.0 - saturate(dot (viewdir, IN.normal));
			//fixed3 emis = _RimColor.rgb * pow (rim, _RimPower)*_AllPower+(_InnerColor.rgb*2*_InnerColorPower);
			//float alpha = (pow (rim, _AlphaPower))*_AllPower;
			//return emis;
			
			//return fixed4(emis,alpha);
		}
		//void surf (Input IN, inout SurfaceOutput o) {
		//fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
		//o.Albedo = c.rgb ;
		//half rim = 1.0 - saturate(dot (normalize(IN.viewDir), o.Normal));
		//o.Emission = _RimColor.rgb * pow (rim, _RimPower)*_AllPower+(_InnerColor.rgb*2*_InnerColorPower);
		//o.Alpha = (pow (rim, _AlphaPower))*_AllPower;
		//}
		ENDCG
		}
	}
Fallback "VertexLit"
}
