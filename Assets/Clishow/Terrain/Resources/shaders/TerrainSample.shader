Shader "wgame/Terrain/Terrain Sample"
{
	Properties
	{
		_Detal("Detal",2D) = "white"{}
		_TerrainColor("Main Color", Color) = (1,1,1,1)
	}

	SubShader
	{
		Tags{ "Queue" = "Background" "RenderType" = "Opaque" }
		LOD 100
		Pass
		{
			Tags{ "LightMode" = "Vertex" }
			CGPROGRAM
			#include "Assets/Clishow/Terrain/Resources/shaders/Terrain_Base.cginc"
			#pragma glsl_no_auto_normalization
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma multi_compile _SELECT_OFF _SELECT_ON  
			#pragma vertex vert_terrain_sample
			#pragma fragment frag_terrain_sample
			ENDCG
		}

	}
}
