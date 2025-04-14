// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ShadowMap" { 
	Properties {
		_ShadowTex ("_ShadowTex", 2D) = "gray" {}
		_Strength("_Strength", Range(0, 0.2)) = 0.1
		_ShadowMapSize("_ShadowMapSize",Float) = 1600
	}
	Subshader {
		Tags {"Queue"="Transparent"}
		Pass {
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			Offset -1, -1
 
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "Assets/Clishow/Terrain/Resources/shaders/CurvedWorld_Base.cginc"
			#include "Assets/Clishow/Terrain/Resources/shaders/Terrain_Base.cginc"
			struct v2f {
				float4 uvShadow : TEXCOORD0;
				float4 pos : SV_POSITION;
				float fog : TEXCOORD2;
			};
			uniform float4x4 ShadowMatrix;

			v2f vert (appdata_base v)
			{
				v2f o;
				o.fog = CalculateFogFactor(v.vertex, _FogLineMax);
				float4x4 matWVP = mul(ShadowMatrix, unity_ObjectToWorld);
				o.uvShadow = mul(matWVP, v.vertex);
				V_CW_TransformPoint(v.vertex);
				o.pos = UnityObjectToClipPos (v.vertex);
				return o;
			}
			
			sampler2D _ShadowMask;
			sampler2D _ShadowTex;
			float _Strength;
			float _ShadowMapSize;
			fixed4 frag (v2f i) : SV_Target
			{
				half2 uv = i.uvShadow.xy / i.uvShadow.w * 0.5 + 0.5;
#if UNITY_UV_STARTS_AT_TOP
				uv.y = 1 - uv.y;
#endif
 				fixed4 res = fixed4(0, 0, 0, 0);
				half4 texS = tex2D(_ShadowTex, uv);
 				if(texS.r > 0)
 				{
 					res.a += _Strength*texS.a;
 				}

 				texS = tex2D(_ShadowTex, uv + half2(-0.94201624/ _ShadowMapSize, -0.39906216/ _ShadowMapSize));
 				if(texS.r > 0)
 				{
 					res.a += _Strength*texS.r;
 				}
 				
 				texS = tex2D(_ShadowTex, uv + half2(0.94558609/ _ShadowMapSize, -0.76890725/ _ShadowMapSize));
 				if(texS.r > 0)
 				{
 					res.a += _Strength*texS.r;
 				}
 				
 				texS = tex2D(_ShadowTex, uv + half2(-0.094184101/ _ShadowMapSize, -0.92938870/ _ShadowMapSize));
 				if(texS.r > 0)
 				{
 					res.a += _Strength*texS.r;
 				}
 				texS = tex2D(_ShadowTex, uv + half2(0.34495938/ _ShadowMapSize, 0.29387760/ _ShadowMapSize));
 				if(texS.r > 0)
 				{
 					res.a += _Strength*texS.r;
 				}
				ApplyFog(res, _FogColor.rgb, i.fog);
				return res;
			}
			ENDCG
		}
	}
}
