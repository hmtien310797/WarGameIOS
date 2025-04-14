// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "TSM2/Transparent2P1"
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
    	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
    	LOD 300
    	ZWrite Off
	   	Cull Back
		Lighting Off
		Fog { Mode Off }
		Blend SrcAlpha OneMinusSrcAlpha
		
		Pass 
		{
			ZWrite On
			ColorMask 0
    	}
    	
        Pass 
        {
            Name "BASE"
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma fragmentoption ARB_precision_hint_fastest
                #include "UnityCG.cginc"
                #pragma glsl_no_auto_normalization
                
                sampler2D _MainTex;
				half4 _MainTex_ST;
				
                struct appdata_base0 
				{
					float4 vertex : POSITION;
					float3 normal : NORMAL;
					float4 texcoord : TEXCOORD0;
				};
				
                 struct v2f 
                 {
                    float4 pos : SV_POSITION;
                    half2 uv : TEXCOORD0;
                    half2 uvn : TEXCOORD1;
                 };
               
                v2f vert (appdata_base0 v)
                {
                    v2f o;
                    o.pos = UnityObjectToClipPos ( v.vertex );
                    float3 n = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
                    n = n * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
                    o.uvn = n.xy;
                   //o.uvn =  mul (UNITY_MATRIX_MV, float4(v.normal,0))*0.5+0.5;
                    o.uv = TRANSFORM_TEX ( v.texcoord, _MainTex );
                    return o;
                }

              	sampler2D _ToonShade;
                fixed _Brightness;
                
                fixed4 _Color;
                
                fixed4 frag (v2f i) : COLOR
                {
					fixed4 toonShade = tex2D( _ToonShade, i.uvn )*_Color;
					
					fixed4 detail = tex2D ( _MainTex, i.uv );
					return  toonShade * detail*_Brightness;
                }
            ENDCG
        }
    }
    CustomEditor "TSM2"
    //Fallback "Diffuse"
}