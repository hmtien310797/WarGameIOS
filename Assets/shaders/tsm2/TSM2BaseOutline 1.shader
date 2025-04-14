// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "TSM2/BaseOutline1"
{
    Properties 
    {
		_MainTex ("Detail", 2D) = "white" {}        								//2
		_ToonShade ("Shade", 2D) = "white" {}  										//3
		_Color ("Base Color", Color) = (1,1,1,1)									//5	       
		_Brightness ("Brightness 1 = neutral", Float) = 1.0							//7	
		[Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull mode", Float) = 2		//9	
		_OutlineColor ("Outline Color", Color) = (0.5,0.5,0.5,1.0)					//10
		_Outline ("Outline width", Float) = 0.01									//11
		_Asymmetry ("OutlineAsymmetry", Vector) = (0.0,0.25,0.5,0.0)     			//13
		[Enum(TRANS_OPTIONS)] _TrOp ("Transparency mode", Float) = 0                //15
		_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5                                  //16
    }
 
    SubShader
    {
        Tags { "RenderType"="Opaque" }
		LOD 250 
        Lighting Off
        Fog { Mode Off }
        
        UsePass "TSM2/Base1/BASE"
        	
        Pass
        {
            Cull Front
            ZWrite On
            CGPROGRAM
			#include "UnityCG.cginc"
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma glsl_no_auto_normalization
			#pragma multi_compile_fog
            #pragma vertex vert
 			#pragma fragment frag
            struct appdata_t 
            {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f 
			{
				float4 pos : SV_POSITION;
				UNITY_FOG_COORDS(0)
			};

            fixed _Outline;
            #if _ASYM_ON
            float4 _Asymmetry;
            #endif
            
            v2f vert (appdata_t v) 
            {
                v2f o;
			    o.pos = v.vertex;
			    #if _ASYM_ON
			    o.pos.xyz += (v.normal.xyz + _Asymmetry.xyz) *_Outline*0.01;
			    #else
			    o.pos.xyz += v.normal.xyz *_Outline*0.01;
			    #endif
			    o.pos = UnityObjectToClipPos(o.pos);		
				UNITY_TRANSFER_FOG(o, o.pos);
			    return o;
            }
            
            fixed4 _OutlineColor;
            
            fixed4 frag(v2f i) :COLOR 
			{
				fixed4 c = _OutlineColor;
				UNITY_APPLY_FOG(i.fogCoord, c);
		    	return c;
			}
            
            ENDCG
        }
    }
    CustomEditor "TSM2"
    //Fallback "Diffuse"
}