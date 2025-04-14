Shader "Custom/Simple Texture Cull Off" {
	Properties {
		_MainTex ("Base (RGBA)", 2D) = "white" {}
		_AdditiveColor ("Additive Color", Color) = (0,0,0,1)
	}
	
	SubShader {
	
	    Tags {"RenderType"="Opaque"}
	    Lighting Off
	    Cull Off
	    	
		BindChannels {
			Bind "Color", color
			Bind "Vertex", vertex
			Bind "TexCoord", texcoord
		}
		
		Pass {
			SetTexture [_MainTex] { combine texture * primary, texture } 
			SetTexture [_] {
            	ConstantColor [_AdditiveColor]
                Combine previous + constant, previous
            }
		}
	}
	FallBack "Mobile/Diffuse"
}