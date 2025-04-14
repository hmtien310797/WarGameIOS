// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Toon/Diffuse" {
	Properties {
		_Color ("Main Color", Color) = (1,1,1,1)
		_OutlineColor ("Outline Color", Color) = (0,0,0,0.5)
		_Outline ("Outline width", Range (.002, 0.03)) = .002
		_AdditiveColor ("Additive Color", Color) = (0,0,0,1)
		_Emission ("Emissive Color", Color) = (0.149,0.149,0.149,0)
		_MainTex ("Base (RGB)", 2D) = "white" { }
	}
	
	CGINCLUDE
	#include "UnityCG.cginc"
	struct appdata {
		float4 vertex : POSITION;
		float3 normal : NORMAL;
	};

	struct v2f {
		float4 pos : POSITION;
		fixed4 color : COLOR;
	};
	
	uniform float _Outline;
	uniform fixed4 _OutlineColor;
	fixed4 _AdditiveColor;
	
	v2f vert(appdata v) {
		v2f o;

		//float4 tangent = float4(1, 1, 1, 1);
		//V_CW_TransformPointAndNormal(v.vertex, v.normal, tangent);
		o.pos = UnityObjectToClipPos(v.vertex);

		float3 norm   = mul ((float3x3)UNITY_MATRIX_IT_MV, v.normal);
		float2 offset = TransformViewToProjection(norm.xy);

		o.pos.xy += offset * o.pos.z * _Outline;
		o.color = _OutlineColor;
		return o;
	}
	ENDCG

	SubShader {
		Tags { "RenderType"="Opaque" "Queue"="Geometry+2"}
		
		UsePass "wgame/Scene/Diffuse/PLAYER"
				
		Pass {
			Name "OUTLINE"
			Tags { "LightMode" = "Always" }
			Cull Front
			ZWrite On
			ColorMask RGB
			Blend SrcAlpha OneMinusSrcAlpha
			Fog { Mode Off }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			fixed4 frag(v2f i) :COLOR { return i.color; }
			ENDCG
		}
	}
	
	Fallback "Diffuse"
}
