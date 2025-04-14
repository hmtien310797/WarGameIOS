Shader "Particles/MaskGlowNoLight" {
	Properties {
		_Color ("Glow Color", Color) = (1,1,1,1)
		_MainTex ("Mask (RGB)", 2D) = "white" {}
		_GlowTex ("Glow (RGB)", 2D) = "white" {}
		_glossiness ("Specular Glossiness(1.0 - 10.0)", Range(1,10)) = 1.0
	}
	SubShader {
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off Lighting Off ZWrite Off Fog { Mode Off }
		
		CGPROGRAM
		#pragma surface surf SimpleLambert

		fixed4 _Color;
		sampler2D _MainTex;
		sampler2D _GlowTex;
		half _glossiness;

		struct Input {
			float2 uv_MainTex;
			float2 uv_GlowTex;
		};

		half4 LightingSimpleLambert (SurfaceOutput s, half3 lightDir, half atten) {
          //half NdotL = dot (s.Normal, lightDir);
          half4 c;
          c.rgb = s.Albedo;// * _LightColor0.rgb * (NdotL * atten * 2);
          c.a = s.Alpha;
          return c;
		  //return half4(1,1,1,1);
      }

		void surf (Input IN, inout SurfaceOutput o) {
			half4 c = tex2D (_MainTex, IN.uv_MainTex);
			half4 g = tex2D (_GlowTex, IN.uv_GlowTex);
			o.Albedo = _glossiness *(c.rgb * _Color.rgb);
			o.Alpha = g.a * c.a * _Color.a;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
