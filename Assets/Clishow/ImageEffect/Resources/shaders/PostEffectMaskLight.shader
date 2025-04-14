// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "wgame/Post/Transparent Mask Light"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}

		CGINCLUDE
		#include"UnityCG.cginc"
		sampler2D _MainTex;
		float4 _MainTex_ST;

		struct v2f_ml
		{
			float4 pos : SV_POSITION;
			float4 color : TEXCOORD1;
			half2 texcoord : TEXCOORD0;
		};

		struct appdata_ml
		{
			float4 vertex : POSITION;
			float4 tangent : TANGENT;
			float4 color : COLOR;
			float4 texcoord : TEXCOORD0;
		};

		v2f_ml vert(appdata_ml v)
		{
			float4 vt =  v.vertex;
			float2 localxz = vt.xz;
			float4 lp = v.tangent;
			vt.xz = vt.xz - ((1 - lp.w )*lp.xz);
			v2f_ml o;
			o.color = v.color;
			o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
			o.pos = UnityObjectToClipPos(vt);
			return o;
		}

		fixed4 frag(v2f_ml i) :COLOR
		{
			fixed c = (1 - tex2D(_MainTex, i.texcoord).r);
			return fixed4(i.color.rgb, 1) *(c) *i.color.a;
		}

		ENDCG


		SubShader
		{
			Tags{ "RenderType" = "PostMask" "Queue" = "Transparent" }
				Blend SrcAlpha One
				Cull Off Lighting Off// ZWrite Off 
				Pass
			{
				Name "MaskLight"
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				ENDCG
			}
		}
}
