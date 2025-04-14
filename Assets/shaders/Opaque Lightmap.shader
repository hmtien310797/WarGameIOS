// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Unlit shader. Simplest possible textured shader.
// - no lighting
// - no projector support

Shader "Custom/Opaque Lightmap" {
Properties {
	//_LightFactor ("Light factor", Range (0.5, 2)) = 1
	_MainTex ("Base (RGBA)", 2D) = "white" {}
	_LighMap ("LightMap (RGB)", 2D) = "white" {}
}

// Simplified VertexLit shader, optimized for high-poly meshes. Differences from regular VertexLit one:
// - less per-vertex work compared with Mobile-VertexLit
// - supports only DIRECTIONAL lights and ambient term, saves some vertex processing power
// - no per-material color
// - no specular
// - no emission
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 80
		
	Pass {
		Name "FORWARD"
		Tags { "LightMode" = "ForwardBase" }
		
CGPROGRAM
#pragma vertex vert_surf
#pragma fragment frag_surf
#pragma fragmentoption ARB_precision_hint_fastest
#pragma multi_compile_fwdbase
#include "HLSLSupport.cginc"
#define UNITY_PASS_FORWARDBASE
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

#define INTERNAL_DATA
#define WorldReflectionVector(data,normal) data.worldRefl
#define WorldNormalVector(data,normal) normal

		inline float3 LightingLambertVS (float3 normal, float3 lightDir)
		{
			fixed diff = max (0, dot (normal, lightDir));
			
			return _LightColor0.rgb * (diff * 2);
		}

		#pragma debug
		//#pragma surface surf Lambert

		sampler2D _MainTex;
		sampler2D _LighMap;

		struct Input {
			half2 uv_MainTex;
			half2 uv2_LighMap;
		};

		void surf (Input IN, inout SurfaceOutput o) {
			o.Albedo = tex2D (_MainTex, IN.uv_MainTex) * tex2D (_LighMap, IN.uv2_LighMap);
		}
		
		
		struct v2f_surf {
		  float4 pos : SV_POSITION;
		  half2 pack0 : TEXCOORD0;
		  fixed3 normal : TEXCOORD1;
		  half2 lmap : TEXCOORD2;
		  fixed3 vlight : TEXCOORD3;
		  LIGHTING_COORDS(4,5)
		};
				
		float4 _MainTex_ST;
		float4 _LighMap_ST;
		
		v2f_surf vert_surf (appdata_full v) {
			v2f_surf o;
			o.pos = UnityObjectToClipPos (v.vertex);
			o.pack0.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
			o.lmap.xy = TRANSFORM_TEX(v.texcoord1, _LighMap);

			float3 worldN = mul((float3x3)unity_ObjectToWorld, SCALED_NORMAL);
			o.normal = worldN;
			o.vlight = ShadeSH9 (float4(worldN,1.0));
			o.vlight += LightingLambertVS (worldN, _WorldSpaceLightPos0.xyz);
			
			TRANSFER_VERTEX_TO_FRAGMENT(o);
			return o;
		}

		fixed4 frag_surf (v2f_surf IN) : COLOR {
			Input surfIN;
			surfIN.uv_MainTex = IN.pack0.xy;
			surfIN.uv2_LighMap = IN.lmap.xy;
			SurfaceOutput o;
			o.Albedo = 0.0;
			o.Emission = 0.0;
			o.Specular = 0.0;
			o.Alpha = 0.0;
			o.Gloss = 0.0;
			o.Normal = IN.normal;
			
			surf (surfIN, o);
			
			fixed atten = LIGHT_ATTENUATION(IN);
			fixed4 c = 0;
			
			c.rgb = o.Albedo * IN.vlight * atten;
			c.a = o.Alpha;

			return c;
		}
	
ENDCG
	}
}

FallBack "Mobile/VertexLit"
}

