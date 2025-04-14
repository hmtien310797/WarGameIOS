Shader "PostEffect"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass //0
		{
			name "color"
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag_color
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "IEInclude.cginc"
			ENDCG
		}

		Pass //1
		{
			name "blur_box"
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag_blur
			#pragma fragmentoption ARB_precision_hint_fastest
			#define BOX_KERNEL
			#define BLUR_RADIUS_3
			#include "IEInclude.cginc"
			ENDCG
		}

		Pass //2
		{
			name "blur_gaussian"
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag_blur
			#pragma fragmentoption ARB_precision_hint_fastest
			#define GAUSSIAN_KERNEL
			#define BLUR_RADIUS_3
			#include "IEInclude.cginc"
			ENDCG
		}

		Pass //3
		{
			name "blur_easy"
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag_blur
			#pragma fragmentoption ARB_precision_hint_fastest
			#define BOX_KERNEL
			#define BLUR_RADIUS_1
			#include "IEInclude.cginc"
			ENDCG
		}

		Pass //4
		{
			name "bloom sample"
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag_bloom_sample
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "IEInclude.cginc"
			ENDCG
		}

		Pass //5
		{
			name "bloom composite"
			CGPROGRAM
			#pragma vertex vert_bloom
			#pragma fragment frag_bloom_composite
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "IEInclude.cginc"
			ENDCG
		}

		Pass //6
		{
			name "mask"
			CGPROGRAM
			#pragma vertex vert_bloom
			#pragma fragment frag_mask
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "IEInclude.cginc"
			ENDCG
		}

		Pass //7
		{
			name "mask blend"
			CGPROGRAM
			#pragma vertex vert_bloom
			#pragma fragment frag_mask_blend
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "IEInclude.cginc"
			ENDCG
		}
		Pass //8
		{
			name "des red"
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag_color_desred
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "IEInclude.cginc"
			ENDCG
		}
	}
}
