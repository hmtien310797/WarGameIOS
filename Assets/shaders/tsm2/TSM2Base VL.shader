// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "TSM2/Base VL" 
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
		_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5                                  //16
		_AmbientColFactor("Ambient Color Factor", Range(0,2)) = 1
    }
   
    Subshader 
    {
    	Tags { "RenderType"="Opaque" }
		LOD 250
    	ZWrite On
	   	Cull [_Cull]
		Lighting On
		Fog { Mode Off }
        Pass 
        {
			Tags{ "LightMode" = "Vertex" }
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
				
				fixed _AmbientColFactor;
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
					fixed4 color : COLOR;
					fixed3 lightColor : TEXCOORD3;
					
                 };
               
				 float3 ShadeVertexLightsFull_Base(float4 vertex, float3 normal, int lightCount, bool spotLight)
				 {
					 float3 viewpos = UnityObjectToViewPos(vertex);
					 float3 viewN = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, normal));

					 float3 lightColor = UNITY_LIGHTMODEL_AMBIENT.xyz*_AmbientColFactor;
					 for (int i = 0; i < lightCount; i++) {
						 float3 toLight = unity_LightPosition[i].xyz - viewpos.xyz * unity_LightPosition[i].w;
						 float lengthSq = dot(toLight, toLight);
						 toLight *= rsqrt(lengthSq);

						 float atten = 1.0 / (1.0 + lengthSq * unity_LightAtten[i].z);
						 if (spotLight)
						 {
							 float rho = max(0, dot(toLight, unity_SpotDirection[i].xyz));
							 float spotAtt = (rho - unity_LightAtten[i].x) * unity_LightAtten[i].y;
							 atten *= saturate(spotAtt);
						 }

						 float diff = max(0.25, dot(viewN, toLight));
						 lightColor += unity_LightColor[i].rgb * (diff * atten);
					 }
					 return lightColor;
				 }
                v2f vert (appdata_base0 v)
                {
                    v2f o;
					o.lightColor = ShadeVertexLightsFull_Base(v.vertex, v.normal,4,false);
                    o.vertex = UnityObjectToClipPos ( v.vertex );
                    float3 n = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
                    n = n * float3(0.5,0.5,0.5) + float3(0.5,0.5,0.5);
                    o.uvn = n.xy;
                   //o.uvn =  mul (UNITY_MATRIX_MV, float4(v.normal,0))*0.5+0.5;
                    o.uv = TRANSFORM_TEX ( v.texcoord, _MainTex );
					o.color = v.color;
					UNITY_TRANSFER_FOG(o, o.vertex);
                    return o;
                }

              	sampler2D _ToonShade;
                fixed _Brightness;
                fixed4 _Color;
                
                fixed4 frag (v2f i) : COLOR
                {
					fixed4 toonShade = tex2D( _ToonShade, i.uvn )*_Color;
					toonShade*=i.color;
					fixed4 detail = tex2D ( _MainTex, i.uv );
					
					fixed4 col = toonShade * detail*_Brightness;
					col *= fixed4(i.lightColor, 1);
					UNITY_APPLY_FOG(i.fogCoord, col);
					return  col;
                }
            ENDCG
        }
    }
    CustomEditor "TSM2"
    Fallback "TSM2/Base1"
}