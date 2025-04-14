// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "TSM2/Base1" 
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
   
    Subshader 
    {
    	Tags { "RenderType"="Opaque" }
		LOD 250
    	ZWrite On
	   	Cull [_Cull]
		Lighting Off
		Fog { Mode Off }
		
        Pass 
        {
            Name "BASE"
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma fragmentoption ARB_precision_hint_fastest
				#pragma multi_compile_fog
                #include "UnityCG.cginc"
                #pragma glsl_no_auto_normalization
                sampler2D _MainTex;
				half4 _MainTex_ST;
				
                struct appdata_base0 
				{
					float4 vertex : POSITION;
					float3 normal : NORMAL;
					float4 texcoord : TEXCOORD0;
					fixed4 color : COLOR;
				};
				
                 struct v2f 
                 {
                    float4 vertex : SV_POSITION;
                    half2 uv : TEXCOORD0;
					UNITY_FOG_COORDS(1)
                    half2 uvn : TEXCOORD2;
					
                 };
               
                v2f vert (appdata_base0 v)
                {
                    v2f o;
                    o.vertex = UnityObjectToClipPos ( v.vertex );
                    float3 n = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
                    n = n * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
                    o.uvn = n.xy;
                   //o.uvn =  mul (UNITY_MATRIX_MV, float4(v.normal,0))*0.5+0.5;
                    o.uv = TRANSFORM_TEX ( v.texcoord, _MainTex );
					UNITY_TRANSFER_FOG(o, o.vertex);
                    return o;
                }

              	sampler2D _ToonShade;
                fixed _Brightness;
                fixed4 _Color;
                
                fixed4 frag (v2f i) : COLOR
                {
					fixed4 toonShade = tex2D( _ToonShade, i.uvn )*_Color;					
					fixed4 detail = tex2D ( _MainTex, i.uv );
					fixed4 col = toonShade * detail*_Brightness;
					UNITY_APPLY_FOG(i.fogCoord, col);
					return  col;
                }
            ENDCG
        }
    }
    CustomEditor "TSM2"
    //Fallback "Diffuse"
}