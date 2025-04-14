// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

#ifndef IE_CGINC_INCLUDE
#define IE_CGINC_INCLUDE

#include "UnityCG.cginc"

uniform half4 _BlurOffsets;
uniform float4 _ColorBoost; // x = Brightness, y = Contrast, z = Saturate, w = Daltonize;
uniform half _BloomThreshold;
uniform half _BloomIntensity;
uniform fixed4 _BloomTint;


struct appdata
{
	float4 vertex : POSITION;
	float2 uv : TEXCOORD0;
};

struct v2f
{
	float2 uv : TEXCOORD0;
	float4 vertex : SV_POSITION;
};

struct v2f_bloom {
	half4 pos : SV_POSITION;
	half4 uv : TEXCOORD0;
};

struct v2f_distortion
{
	half4 pos : SV_POSITION;
	half4 uvgrab : TEXCOORD0;
	half2 uv : TEXCOORD1;

};

sampler2D _MainTex;
float4 _MainTex_TexelSize;

#ifdef RGBM_DECODE
#undef BLUR_ALPHA_CHANNEL
#endif

//No radius defined?
#if !defined(BLUR_RADIUS_10) && !defined(BLUR_RADIUS_5) && !defined(BLUR_RADIUS_3) && !defined(BLUR_RADIUS_2) && !defined(BLUR_RADIUS_1)
#define BLUR_RADIUS_5
#endif

inline fixed4 SampleTex(sampler2D _tex, half2 _uv) {
	fixed4 tex = tex2Dlod(_tex, half4(_uv.x, _uv.y, 0, 0));

#ifdef RGBM_DECODE
	return fixed4(tex.rgb * tex.a * 8, tex.a);
#else
	return tex;
#endif
}

inline fixed4 BlurTex(sampler2D _tex, v2f input, half _stepSizeScale) {
#ifdef GAUSSIAN_KERNEL
#ifdef BLUR_RADIUS_10
#ifndef SQRT_KERNEL
	half blurKernel[21] = { 0.0000009536743, 0.00001907349, 0.0001811981, 0.001087189, 0.004620552, 0.01478577, 0.03696442, 0.07392883, 0.1201344, 0.1601791, 0.1761971,
		0.1601791, 0.1201344, 0.07392883, 0.03696442, 0.01478577, 0.004620552, 0.001087189, 0.0001811981, 0.00001907349, 0.0000009536743 };
#else
	half blurKernel[21] = { 0.00029375321, 0.00131370447, 0.00404910851, 0.00991825158, 0.02044699669, 0.03657670408, 0.0578328432, 0.08178798567, 0.10425965597, 0.1203886433, 0.12626470656,
		0.1203886433, 0.10425965597, 0.08178798567, 0.0578328432, 0.03657670408, 0.02044699669, 0.00991825158, 0.00404910851, 0.00131370447, 0.00029375321 };
#endif
#endif

#ifdef BLUR_RADIUS_5
	half blurKernel[11] = { 0.0009765625, 0.009765625, 0.04394531, 0.1171875, 0.2050781, 0.2460938, 0.2050781, 0.1171875, 0.04394531, 0.009765625, 0.0009765625 };
#endif

#ifdef BLUR_RADIUS_3
	half blurKernel[7] = { 0.015625, 0.09375, 0.234375, 0.3125, 0.234375, 0.09375, 0.015625 };
#endif

#ifdef BLUR_RADIUS_2
	half blurKernel[5] = { 0.0625, 0.25, 0.375, 0.25, 0.0625 };
#endif

#ifdef BLUR_RADIUS_1
	half blurKernel[3] = { 0.25, 0.5, 0.25 };
#endif
#endif

#ifdef BLUR_RADIUS_10
	const int blurRadius = 10;
#endif

#ifdef BLUR_RADIUS_5
	const int blurRadius = 5;
#endif

#ifdef BLUR_RADIUS_3
	const int blurRadius = 3;
#endif

#ifdef BLUR_RADIUS_2
	const int blurRadius = 2;
#endif

#ifdef BLUR_RADIUS_1
	const int blurRadius = 1;
#endif

	half2 finalStepSize = _BlurOffsets.xy * _stepSizeScale;

	half4 res = half4(0, 0, 0, 0);

#ifdef BOX_KERNEL
	half boxWeight = 1.0 / half(blurRadius * 2 + 1);
#endif

	for (int i = 0; i <= blurRadius * 2; i++) {
		half2 curUV = input.uv + _MainTex_TexelSize.xy * finalStepSize * half(i - blurRadius);

#ifdef BLUR_ALPHA_CHANNEL
#ifdef GAUSSIAN_KERNEL
		res += SampleTex(_tex, curUV) * blurKernel[i];
#elif defined(BOX_KERNEL)
		res += SampleTex(_tex, curUV) * boxWeight;
#endif
#else
#ifdef GAUSSIAN_KERNEL
		res.rgb += SampleTex(_tex, curUV).rgb * blurKernel[i];
#elif defined(BOX_KERNEL)
		res.rgb += SampleTex(_tex, curUV).rgb * boxWeight;
#endif
#endif
	}

#ifndef IGNORE_ALPHA_CHANNEL
#ifndef BLUR_ALPHA_CHANNEL
	fixed4 centralPixel = SampleTex(_tex, input.uv);

	//!!!!!Discards all black pixels!!!!!
#ifdef COLORIZE_WITH_CENTRAL_PIXEL
	res.rgb *= centralPixel.rgb;
#endif

	res.a = centralPixel.a;
#endif
#endif

	return res;
}

const float3 halves = float3(0.5, 0.5, 0.5);

float getCurve(float x, float m, float w) {
	x = abs(x - m);
	if (x<w) return 1.0;
	x /= (x + w * 1.1);
	return 1.0 - x*x*(3.0 - 2.0*x);
}

float getLuma(float3 rgb) {
	const float3 lum = float3(0.299, 0.587, 0.114);
	return dot(rgb, lum);
}

void ColorAdjust(v2f i, inout half3 rgbM) {
	half  lumaM = getLuma(rgbM);

	half3 maxComponent = max(rgbM.r, max(rgbM.g, rgbM.b));
	half3 minComponent = min(rgbM.r, min(rgbM.g, rgbM.b));
	half  sat = saturate(maxComponent - minComponent);
	rgbM *= 1.0 + _ColorBoost.z * (1.0 - sat) * (rgbM - getLuma(rgbM));

	rgbM = (rgbM - halves) * _ColorBoost.y + halves;
	rgbM *= _ColorBoost.x;
	rgbM = lerp(rgbM, getLuma(rgbM), _ColorBoost.w);
}

v2f vert(appdata v)
{
	v2f o;
	o.vertex = UnityObjectToClipPos(v.vertex);
	o.uv = v.uv;
	return o;
}

float4 frag_color(v2f i) : SV_TARGET{
	float4 pixel = tex2D(_MainTex, i.uv);
	ColorAdjust(i, pixel.rgb);
	return pixel;
}

fixed4 frag_color_desred(v2f i) : SV_TARGET{
	float4 pixel = tex2D(_MainTex , i.uv);
	fixed4 resColor = float4(1,0,0,1)*0.25 + pixel*0.75;
	return resColor;
}

fixed4 frag_blur(v2f i) : SV_Target
{
	return BlurTex(_MainTex, i, 1);
}

v2f_bloom vert_bloom(appdata v)
{
	v2f_bloom o;
	o.pos = UnityObjectToClipPos(v.vertex);
	o.uv = v.uv.xyxy;
	#if UNITY_UV_STARTS_AT_TOP  
	if (_MainTex_TexelSize.y < 0.0)
		o.uv.w = 1.0 - o.uv.w;
	#endif  
	return o;
}

sampler2D _BloomTex;

fixed4 frag_bloom_sample(v2f i) : COLOR
{
	fixed4 mainTex = tex2D(_MainTex, i.uv);
	fixed finalLum = Luminance(mainTex.rgb);
	finalLum = (finalLum - _BloomThreshold) / (1.0 - _BloomThreshold);	
	mainTex.rgb *= finalLum;
	return mainTex;
}

fixed4 frag_bloom_composite(v2f_bloom i) : COLOR
{
	fixed4 color = tex2D(_MainTex, i.uv.xy);
	color += tex2D(_BloomTex, i.uv.zw)*_BloomIntensity*_BloomTint;
	return color;
}

sampler2D _Mask_Blend_Tex;

sampler2D _Mask_Distortion_Blend_Tex;

sampler2D _DistortionNoiseTEx;

sampler2D _MaskTex;

fixed4 frag_mask(v2f_bloom i) : COLOR
{
	fixed4 color = tex2D(_MainTex, i.uv.xy);
	color *= tex2D(_MaskTex, i.uv.zw);
	return color;
}

fixed4 frag_mask_blend(v2f_bloom i) : COLOR
{
	//fixed mask =tex2D(_MaskTex, i.uv).g;
	//half4 offsetColor1 = tex2D(_DistortionNoiseTEx, i.uv + _Time.xz*0.045);
	//half4 offsetColor2 = tex2D(_DistortionNoiseTEx, i.uv - _Time.yx*0.045);
	//i.uv.x += ((offsetColor1.r + offsetColor2.r) - 1)  * mask*0.0125;
	//i.uv.y += ((offsetColor1.g + offsetColor2.g) - 1)  * mask*0.0125;
	fixed4 renderTex = tex2D(_MainTex, i.uv.xy);;
	renderTex += tex2D(_Mask_Blend_Tex, i.uv.zw);
	return renderTex;
}

#endif