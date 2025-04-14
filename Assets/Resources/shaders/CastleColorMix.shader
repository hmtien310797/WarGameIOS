// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Castle/ColorMix" {
Properties {
// 基本贴图
_MainTex ("Texture Image", 2D) = "white" {} 
// 爆光度
_Explosure("Explosure", Float) = 1.0
// 整体提亮
_HighLight("HighLight", Float) = 0
// 混入黑白
_Brightness("Brightness", Float) = 0
// 这里是混入各颜色分量
_Color ("Main Color", COLOR) = (0,0,0,0)
}
SubShader {
Pass {	
CGPROGRAM

#pragma vertex vert 
#pragma fragment frag 

uniform sampler2D _MainTex;	
uniform float4 _MainTex_ST; 
uniform float _Explosure;
uniform float _HighLight;
uniform float _Brightness;
uniform float4 _Color;

struct vertexInput {
float4 vertex : POSITION;
float4 texcoord : TEXCOORD0;
};
struct vertexOutput {
float4 pos : SV_POSITION;
float4 tex : TEXCOORD0;
};

vertexOutput vert(vertexInput input) 
{
vertexOutput output;

output.tex = input.texcoord;
output.pos = UnityObjectToClipPos(input.vertex);
return output;
}

float4 frag(vertexOutput input) : COLOR
{

// 这里改为：先混色偏，再曝光
return (tex2D(_MainTex, _MainTex_ST.xy * input.tex.xy + _MainTex_ST.zw) + _Color) * _Explosure
+ float4(0.21 * _HighLight, 0.72 * _HighLight, 0.07 *_HighLight, 1.0)
+ float4(_Brightness,_Brightness,_Brightness, 0.0);	
}

ENDCG
}
}
}