// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "wgame/Terrain/VFX Ghost"
{
	Properties
	{
		_OutColor("OutColor", Color) = (0,0.7450981,0.9490197,1)
		_InColor("InColor", Color) = (1,0,0,1)
		_Strength("Strength", Float) = 1
		_Glow("Glow", Float) = 1
		_MainTex("MainTex", 2D) = "white" {}
	}

		CGINCLUDE
			#include"UnityCG.cginc"
			float4 _OutColor;
			float4 _InColor;
			float _Strength;
			float _Glow;
			sampler2D _MainTex;	float4 _MainTex_ST;
			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 texcoord0 : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv0 : TEXCOORD0;
				float4 posWorld : TEXCOORD1;
				float3 normalDir : TEXCOORD2;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.uv0 = v.texcoord0;
				o.normalDir = UnityObjectToWorldNormal(v.normal);
				o.posWorld = mul(unity_ObjectToWorld, v.vertex);
				o.pos = UnityObjectToClipPos(v.vertex);
				return o;
			}

			fixed4 frag(v2f i) :SV_Target
			{
				i.normalDir = normalize(i.normalDir);
				float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
				float3 normalDirection = i.normalDir;
				fixed4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
				fixed3 emissive = (_Glow*lerp(_InColor.rgb,_OutColor.rgb,pow(1.0 - max(0,dot(normalDirection, viewDirection)),_Strength))*_MainTex_var.rgb);
				fixed3 finalColor = emissive;
				return fixed4(finalColor,1);
			}
		ENDCG


	SubShader
	{
		Tags{ "IgnoreProjector" = "True" "Queue" = "Transparent"  "RenderType" = "Transparent" }
			Blend One One
			ZTest NotEqual
			ZWrite Off
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}
