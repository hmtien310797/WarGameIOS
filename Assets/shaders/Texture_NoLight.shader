Shader "Custom/Texture_NoLight" {
	Properties {
		_MainTex ("Base (RGBA)", 2D) = "white" {}
		_AdditiveColor ("Additive Color", Color) = (0,0,0,1)
	}
	
	SubShader {
	
	    Tags {"RenderType"="Opaque"}
	    Lighting Off
		
		Pass {
			SetTexture [_MainTex] {
            	ConstantColor [_AdditiveColor]
                Combine texture + constant, texture
            }
		}
	}
	FallBack "Mobile/Diffuse"
}
