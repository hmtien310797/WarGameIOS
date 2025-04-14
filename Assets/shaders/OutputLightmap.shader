// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ReplaceLightmap/OutputLightmap"
 {
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}
    CGINCLUDE
    #include "UnityCG.cginc"

    uniform sampler2D _MainTex;
        
    struct VS_OUTPUT
    {
         float4 Position : SV_POSITION;
		 half2 vTexcoord : TEXCOORD0;
    };
            
    VS_OUTPUT MainVS(appdata_base input)
    {
          VS_OUTPUT output = (VS_OUTPUT)0;
                
          output.Position = UnityObjectToClipPos(input.vertex);
          output.vTexcoord = input.texcoord;

          return output;
     }
     
     fixed3 UnityDecodeLightmap(fixed4 color)
     {
	     return (8.0 * color.a) * color.rgb;
     }
     
     //FP32(RGB) to LogLUV
     fixed4 EncodeLogLuv(fixed3 vRGB)
     {
	     fixed3x3 M = fixed3x3(
		 0.2209, 0.3390, 0.4184,
		 0.1138, 0.6780, 0.7319,
		 0.0102, 0.1130, 0.2969);

	     fixed4 vResult;
	     fixed3 Xp_Y_XYZp = mul(vRGB, M);
	     Xp_Y_XYZp = max(Xp_Y_XYZp, fixed3(1e-6, 1e-6, 1e-6));
	     vResult.xy = Xp_Y_XYZp.xy / Xp_Y_XYZp.z;
	     fixed Le = 2 * log2(Xp_Y_XYZp.y) + 127;
	     vResult.w = frac(Le);
	     vResult.z = (Le - (floor(vResult.w*255.0f)) / 255.0f) / 255.0f;
	     return vResult;
	 }


     fixed4 MainPS(VS_OUTPUT input) : COLOR
     {
		 fixed4 vLightmapColor = tex2D(_MainTex, input.vTexcoord);
	     fixed3 color = UnityDecodeLightmap(vLightmapColor);
		 return EncodeLogLuv(color.rgb);
     }
     
    ENDCG
    SubShader 
	{
        Tags{ "RenderType" = "Opaque"}

		Pass
		{
        	Name "LightmapDecode"
        	Lighting Off
			ZWrite Off
			AlphaTest Off
			CGPROGRAM

            #pragma vertex MainVS
            #pragma fragment MainPS
            #pragma target 2.0
           
            ENDCG
		}
    }
}
