// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_World2Shadow' with 'unity_WorldToShadow[0]'

Shader "wgame/World Map/Diffuse Shadow"
{
	Properties
	{
		_Color("Main Color", Color) = (1,1,1,1)
		_MainTex("Texture", 2D) = "white" {}
		_Deepness("depth", Range(0,1)) = 1
	}

		CGINCLUDE
		#include"UnityCG.cginc"
		sampler2D _MainTex;
		float4 _MainTex_ST;
		float4 _Color;

		struct appdata
		{
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			fixed4 color : COLOR;
			float4 texcoord : TEXCOORD0;
		};

		struct v2f_dif
		{
			float4 pos : SV_POSITION;
			fixed4 color : COLOR;
			float2 uv : TEXCOORD0;
		};

		v2f_dif vert_dif(appdata v)
		{
			v2f_dif o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.color = v.color;
			o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
			return o;
		}

		fixed4 frag_dif(v2f_dif i) :SV_Target
		{
			fixed4 texcol = tex2D(_MainTex, i.uv);
			fixed4 c = (texcol*_Color);
			return c;
		}

		float _Deepness;
		float4 _ShadowOffset;
		uniform float4x4 _World2PShadow;
		uniform float4x4 _PShadow2World;
		struct v2f_shadow
		{
			float4 pos : SV_POSITION;
		};

		v2f_shadow vert_shadow(appdata v)
		{
			float4 whight = float4(0, -1 * _ShadowOffset.y, 0,0);
			whight = mul(_World2PShadow, whight);
			float hight = whight.y;
			float4 vt = v.vertex;
			vt = mul(unity_ObjectToWorld, vt);
			vt = mul(_World2PShadow, vt);
			vt.xz += _ShadowOffset.xz;
			vt.y += hight;
			vt = mul(_PShadow2World, vt);
			vt = mul(unity_WorldToObject, vt);

			v2f_shadow o;
			o.pos = UnityObjectToClipPos(vt);
			return o;
		}

		fixed4 frag_shadow(v2f_shadow i) :COLOR
		{
			return  fixed4(_Deepness,_Deepness,_Deepness,1);
		}

			ENDCG

		SubShader
		{
			Tags{ "RenderType" = "Transparent" }

			LOD 100

			Pass
			{
				CGPROGRAM
				#pragma vertex vert_dif  
				#pragma fragment frag_dif
				ENDCG
			}

			Pass
			{
				stencil
				{
					Ref 1
					Comp Greater
					Pass Replace
					Fail Zero
					ZFail Zero
				}
				Blend DstColor SrcColor
				CGPROGRAM
				#pragma vertex vert_shadow  
				#pragma fragment frag_shadow
				ENDCG
			}
		}
}
