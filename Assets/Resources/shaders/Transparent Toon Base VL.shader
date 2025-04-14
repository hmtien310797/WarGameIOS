// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "wgame/Obj/Transparent Toon Base VL"
{
	Properties
	{
		_MainTex("Detail", 2D) = "white" {}
		_Brightness("Brightness 1 = neutral", Float) = 1.0
		_OutlineColor("Outline Color", Color) = (0.5,0.5,0.5,1.0)					
		_Outline("Outline width", Float) = 0.01
		_Color("Base Color", Color) = (1,1,1,1)
	}
	CGINCLUDE
		#include "UnityCG.cginc"

		sampler2D _MainTex;
		half4 _MainTex_ST;
		fixed _Outline;
		fixed4 _OutlineColor;
		fixed _Brightness;
		float4 _Color;

		struct appdata
		{
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float4 texcoord : TEXCOORD0;
		};

		struct v2f
		{
			float4 vertex : SV_POSITION;
			half2 uv : TEXCOORD0;
			UNITY_FOG_COORDS(1)
			half2 uvn : TEXCOORD2;
			fixed3 lightColor : TEXCOORD3;
		};

		v2f vert(appdata v)
		{
			v2f o;
			o.lightColor = ShadeVertexLights(v.vertex, v.normal);
			o.vertex = UnityObjectToClipPos(v.vertex);
			float3 n = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
			n = n * float3(0.5, 0.5, 0.5) + float3(0.5, 0.5, 0.5);
			o.uvn = n.xy;
			o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
			UNITY_TRANSFER_FOG(o, o.vertex);
			return o;
		}

		fixed4 frag(v2f i) : COLOR
		{
			fixed4 detail = tex2D(_MainTex, i.uv);
			fixed4 col = detail*_Brightness*_Color;
			col *= fixed4(i.lightColor, 1);
			UNITY_APPLY_FOG(i.fogCoord, col);
			return  col;
		}

		struct appdata_outline
		{
			float4 vertex : POSITION;
			float3 normal : NORMAL;
		};

		struct v2f_outline
		{
			float4 pos : SV_POSITION;
			UNITY_FOG_COORDS(0)
		};

		v2f_outline vert_outline(appdata_outline v)
		{
			v2f_outline o;
			o.pos = v.vertex;
			o.pos.xyz += v.normal.xyz *_Outline*0.01;
			o.pos = UnityObjectToClipPos(o.pos);
			UNITY_TRANSFER_FOG(o, o.pos);
			return o;
		}

		fixed4 frag_outline(v2f_outline i) :COLOR
		{
			fixed4 c = _OutlineColor;
			c.a *= _Color.a;
			UNITY_APPLY_FOG(i.fogCoord, c);
			return c;
		}
	ENDCG




	SubShader
	{
		Tags{ "Queue" = "Transparent"  "RenderType" = "Transparent" }
		LOD 100
		Blend SrcAlpha OneMinusSrcAlpha
		Pass
		{
			Tags{ "LightMode" = "Vertex" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			ENDCG
		}

		//Pass
		//{
		//	Cull Front
		//	ZWrite On
		//	CGPROGRAM
		//	#pragma vertex vert_outline
		//	#pragma fragment frag_outline
		//	// make fog work
		//	#pragma multi_compile_fog
		//	ENDCG
		//}		
	}
}
