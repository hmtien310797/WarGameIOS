// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Castle/ColorMix" {
Properties {
// ������ͼ
_MainTex ("Texture Image", 2D) = "white" {} 
// �����
_Explosure("Explosure", Float) = 1.0
// ��������
_HighLight("HighLight", Float) = 0
// ����ڰ�
_Brightness("Brightness", Float) = 0
// �����ǻ������ɫ����
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

// �����Ϊ���Ȼ�ɫƫ�����ع�
return (tex2D(_MainTex, _MainTex_ST.xy * input.tex.xy + _MainTex_ST.zw) + _Color) * _Explosure
+ float4(0.21 * _HighLight, 0.72 * _HighLight, 0.07 *_HighLight, 1.0)
+ float4(_Brightness,_Brightness,_Brightness, 0.0);	
}

ENDCG
}
}
}