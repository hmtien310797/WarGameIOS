Shader "wgame/Terrain/ColorBlendHighMap 8"
{
	Properties
	{
		_Displacement("Displacement", Float) = 1.5
		_Blend("Blend",2D) = "white"{}
		_DetalBlend("DetalBlend",2D) = "white"{}
		_Detal("Detal",2D) = "white"{}

		_WaterMainTex("Wate Base", 2D) = "white" {}
		_WaterNoiseTex("Wave Noise", 2D) = "white" {}

		_WaterSetting("Water Setting", Vector) = (5,0.1,0.15,0.05)
		_WaterTwistSetting("Water Twist Setting", Vector) = (1.0,1.01,1.0,1.0)
		_Cube("Reflection Map", Cube) = "" {}
		_WaterIndentity("Water Indentity",Float) = 1.75
		_SpecularIndentity("Water Specular Indentity",Float) = 0.25
		_BorderSize("Border Size",Float) = 0.15


	}
	SubShader
	{
		Tags{ "RenderType" = "Opaque" }
			LOD 100

		Pass
		{
			Tags{ "LightMode" = "Vertex" }
			CGPROGRAM
			#include "Assets/Clishow/Terrain/Resources/shaders/Terrain_Base.cginc"
			#pragma glsl_no_auto_normalization
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma multi_compile _DETal8 _DETal4 _DETal2
			#pragma multi_compile _SELECT_OFF _SELECT_ON  
			#pragma multi_compile _BORDER_OFF _BORDER_ON
			#pragma vertex vert_terrain
			#pragma fragment frag_terrain

			ENDCG
		}

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			Tags{ "LightMode" = "Vertex" }
			CGPROGRAM
			#include "Assets/Clishow/Terrain/Resources/shaders/Terrain_Base.cginc"
			#pragma glsl_no_auto_normalization
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma multi_compile WATER_REFL_ON  WATER_REFL_OFF  
			#pragma multi_compile WATER_SPEC_ON  WATER_SPEC_OFF

			#pragma vertex vert_terrain_water
			#pragma fragment frag_terrain_water
			ENDCG
		}
	}
}
