// Upgrade NOTE: replaced '_World2Shadow' with 'unity_WorldToShadow[0]'

Shader "wgame/Terrain/Diffuse Shadow Base"
{
		SubShader
		{
			Tags{ "Queue" = "Background+10" "RenderType" = "Transparent" }
			LOD 100
			Pass
			{
				Name "SHADOW"
				stencil
				{
					Ref 5
					Comp Greater
					Pass Replace
					Fail Replace
					ZFail Replace
				}

				Blend DstColor SrcColor
				CGPROGRAM
				#include "Assets/Clishow/Terrain/Resources/shaders/Terrain_Base.cginc"
				#pragma vertex vert_shadow  
				#pragma fragment frag_shadow
				ENDCG
			}
		}
}
