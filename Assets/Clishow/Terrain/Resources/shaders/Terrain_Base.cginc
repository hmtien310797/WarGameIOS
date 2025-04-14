// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

#ifndef TERRAIN_BASE_CGINC
#define TERRAIN_BASE_CGINC 

#include "UnityCG.cginc"
#include "Assets/Clishow/Terrain/Resources/shaders/CurvedWorld_Base.cginc"
//Он

uniform float _FogLineMax;
uniform float4 _FogColor;

inline float FogEaseInQuart(float start, float end, float value) {
	end -= start;
	return end * value * value * value * value + start;
}

inline float CalculateFogFactor(float4 vertex, fixed fogLineMax)
{
	return 0;
	//float4 wp = mul(unity_ObjectToWorld, vertex);
	//float f = distance(_WorldSpaceCameraPos.xz, wp.xz);
	//return  1 - FogEaseInQuart(0, 1, saturate(f / max(0.1, fogLineMax)));
}

inline void ApplyFog(inout fixed4 color, fixed3 fog_color, fixed factor)
{
	//color.rgb = lerp(fog_color, color.rgb, factor);
}

uniform sampler2D _BorderMarkersGraphic;
uniform sampler2D _BorderMarkersPositionData;
uniform fixed4 _BorderMarkerSettings;
uniform fixed4 _TerrainWorldSettings;
uniform fixed4 _CoreAreaSettings;
uniform float4 _SelectSetting;
uniform fixed _BorderSize;

inline fixed IsInCoreArea(float3 wpos)
{
	float2 pos = wpos.xz -_TerrainWorldSettings.xx*0.5;
	pos = floor( pos/ _TerrainWorldSettings.x);
	pos.x = floor( fmod(pos.x, _TerrainWorldSettings.y));
	pos.x += (1 - step(0, pos.x))*_TerrainWorldSettings.y;
	pos.y = floor( fmod(pos.y, _TerrainWorldSettings.y));
	pos.y += (1 - step(0, pos.y))*_TerrainWorldSettings.y;
	//return ((pos.x) / _TerrainWorldSettings.y);
	return 
		step(0, max(pos.x - _CoreAreaSettings.x + 0.1, -1))*
		step(0, max(pos.y - _CoreAreaSettings.y + 0.1, -1))*
		step(0, max(_CoreAreaSettings.z - pos.x + 0.1, -1))*
		step(0, max(_CoreAreaSettings.w - pos.y + 0.1, -1));
}

inline fixed IsInMainServerBorder(float3 wpos)
{
	float2 pos = wpos.xz + _TerrainWorldSettings.xx*0.5;
	pos = floor(pos / _TerrainWorldSettings.x);

	return 
		step(0, max(pos.x + 0.1, -1))*
		step(0, max(pos.y + 0.1, -1))*
		step(0, max(_TerrainWorldSettings.y - pos.x - 0.1, -1))*
		step(0, max(_TerrainWorldSettings.y - pos.y - 0.1, -1));
}

inline void ConvertMainServerColor(float3 wpos, inout fixed4 color)
{
	fixed msb = IsInMainServerBorder(wpos);
	color.rgb = color.rgb*msb + (1 - msb)*dot(color.rgb, fixed3(.222, .707, .071));
}

inline fixed2 ConvertToBorderUV(fixed4 v, fixed border_unit_size)
{
	fixed2 X = fixed2(border_unit_size, 0);
	fixed2 Y = fixed2(0, border_unit_size);
	return X * v.x + Y * v.y;
}
inline fixed4 GetBorderCoord(float2 pos, fixed border_unit_size, fixed2 w2l_offset)
{
	float2 lpos = pos;// +w2l_offset*0.5;
	lpos = fmod(pos, w2l_offset);
	lpos += w2l_offset*0.5;
	float x = ((lpos.x) / border_unit_size);
	float y = ((lpos.y) / border_unit_size);
	fixed4 b;
	b.x = floor(x);
	b.y = floor(y);
	fixed2 center = ConvertToBorderUV(b, border_unit_size);
	fixed2 offset = lpos - center;
	fixed border_size = _BorderSize;
	b.zw = offset*border_size + fixed2(0.165, 0.165);
	return b;
}

inline fixed4 GetMarkerColor(fixed4 data, fixed4 setting, fixed2 uv)
{
	int type =  round(data.a * setting.x*setting.y);
	fixed sx = 1 / setting.x;
	uv.x = (uv.x + fmod(type, setting.x)) *sx;
	uv.y = (uv.y + ceil(setting.y - (type + 0.01)*sx)) / setting.y;
	fixed4 marker = tex2D(_BorderMarkersGraphic, uv);
	marker.rgb = marker.rgb * data.rgb;
	marker *= step(1, type);
	return marker;
}

inline fixed4 GetBorderColor(float4 wpos)
{
	fixed4 bs = _BorderMarkerSettings;
	float2 pos = float2(wpos.x, wpos.z);
	fixed4 v = GetBorderCoord(pos, bs.w, fixed2(_TerrainWorldSettings.x, _TerrainWorldSettings.x));

	fixed trueDataResolution = bs.z;
	fixed2 dataUV = fixed2(((v.x) + 0.5) / trueDataResolution, ((v.y) + 0.5) / trueDataResolution);
	fixed4 data = tex2D(_BorderMarkersPositionData, dataUV);
	return GetMarkerColor(data, _BorderMarkerSettings, v.zw);
}

inline float GetSelectFactor(float4 wpos)
{
	float2 lpos = float2(abs(wpos.x - _SelectSetting.x), abs(wpos.z - _SelectSetting.y));
	lpos.x = min(1, int(lpos.x / _SelectSetting.z));
	lpos.y = min(1, int(lpos.y / _SelectSetting.w));
	return 1 - min(1, lpos.x + lpos.y);
}

inline fixed3 LocalCorrect(fixed3 origVec, fixed3 vertexPos)
{
	fixed3 bboxMin = fixed3(-1000 * (1 + (int)(abs(_WorldSpaceCameraPos.x) / 500)),
		-1000 * (1 + (int)(abs(_WorldSpaceCameraPos.y) / 500)),
		-1000 * (1 + (int)(abs(_WorldSpaceCameraPos.z) / 500)));
	fixed3 bboxMax = fixed3(1000 * (1 + (int)(abs(_WorldSpaceCameraPos.x) / 500)),
		1000 * (1 + (int)(abs(_WorldSpaceCameraPos.y) / 500)),
		1000 * (1 + (int)(abs(_WorldSpaceCameraPos.z) / 500)));
	fixed3 invOrigVec = fixed3(1.0, 1.0, 1.0) / origVec;
	fixed3 intersecAtMaxPlane = (bboxMax - vertexPos) * invOrigVec;
	fixed3 intersecAtMinPlane = (bboxMin - vertexPos) * invOrigVec;
	fixed3 largestIntersec = max(intersecAtMaxPlane, intersecAtMinPlane);
	// Get the closest of all solutions
	fixed Distance = min(min(largestIntersec.x, largestIntersec.y), largestIntersec.z);
	fixed3 IntersectPositionWS = vertexPos + origVec * Distance - _WorldSpaceCameraPos.xyz;
	return IntersectPositionWS;
}


uniform float _Displacement;
uniform sampler2D _Blend;
uniform sampler2D _DetalBlend;
uniform sampler2D _Detal;
uniform float4 _Detal_ST;

uniform sampler2D _NormalMap;
uniform float3 _NormalLightDir;

uniform float4 _TerrainColor;

struct appdata_terrain
{
	float4 vertex : POSITION;
	float3 normal : NORMAL;
	fixed4 color : COLOR;
	float4 texcoord : TEXCOORD0;
};

struct v2f_terrain
{
	float4 pos : SV_POSITION;
	float4 uv : TEXCOORD0;
	float4 sf : TEXCOORD1;
	float4 wpos : TEXCOORD2;
	fixed3 lightColor : TEXCOORD3;
	fixed select : TEXCOORD4;
};

struct v2f_terrain_sample
{
	float4 pos : SV_POSITION;
	float2 uv : TEXCOORD0;
	float coreArea : TEXCOORD1;
	float4 wpos : TEXCOORD2;
	fixed3 lightColor : TEXCOORD3;
	fixed4 color : TEXCOORD4;
	fixed select : TEXCOORD5;
};

inline v2f_terrain_sample vert_terrain_sample(appdata_terrain v)
{
	v2f_terrain_sample o;
	o.color = v.color;
	o.wpos = mul(unity_ObjectToWorld, v.vertex);
	o.coreArea = IsInCoreArea(o.wpos);
	o.uv = TRANSFORM_TEX(v.texcoord, _Detal);
	o.lightColor = ShadeVertexLights(v.vertex, v.normal);
	o.pos = UnityObjectToClipPos(v.vertex);
	o.select = 0;
#ifdef _SELECT_ON
	o.select = (1 + sin(_Time.y * 15))*0.2;
#endif
	return o;
}

inline v2f_terrain vert_terrain(appdata_terrain v)
{
	v2f_terrain o;
	o.wpos = mul(unity_ObjectToWorld, v.vertex);
	o.sf = float4(0, 0, 0, 0);
	o.sf.y = CalculateFogFactor(v.vertex, _FogLineMax);
	//float h = (v.color.r) * max(0.1, _Displacement);
	o.sf.z = IsInCoreArea(o.wpos);
	o.sf.x = saturate(max(v.color.g, o.sf.z*0.5)) * 4 ;
	o.uv.xy = v.color.ba;
	o.uv.y = 1 - o.uv.y;
	//v.vertex.xyz += v.normal * h;
	V_CW_TransformPoint(v.vertex);
	o.lightColor = ShadeVertexLights(v.vertex, v.normal);
	o.pos = UnityObjectToClipPos(v.vertex);
	o.uv.zw = TRANSFORM_TEX(v.texcoord, _Detal);
	o.select = 0;
#ifdef _SELECT_ON
	o.select = (1 + sin(_Time.y * 15))*0.2;
#endif
	return o;
}


fixed4 blend_terrain16(v2f_terrain i)
{
	fixed depth = 0.5;
	fixed2 fduv = frac(i.uv.zw)*fixed2(0.25, 0.25);

	fixed2 uvb = i.uv.yx;
	fixed2 uv;
	fixed4 c = fixed4(1, 1, 1, 1);
	fixed4 b = tex2D(_Blend, (uvb));
	fixed blendtype1 = (b.r);// +0.03125;
	fixed blendtype2 = (b.b);// b.b;// +0.03125;
	fixed blend1 = b.g;
	fixed blend2 = b.a;
	int type = round(blendtype1 * 16);
	uv.x = fmod(type, 4) *0.25;
	uv.y = (3.0 - floor(type*0.25)) *0.25;
	fixed4 c0 = tex2D(_Detal, fduv + uv);
	type = round(blendtype2 * 16);
	uv.x = fmod(type, 4) *0.25;
	uv.y = (3.0 - floor(type*0.25)) *0.25;
	fixed4 c1 = tex2D(_Detal, fduv + uv);


	fixed ma = max(c0.a + blend1, c1.a + blend2) - depth;


	fixed b1 = max(c0.a + blend1 - ma, 0);
	fixed b2 = max(c1.a + blend2 - ma, 0);

	c.rgb = (c0.rgb*b1 + c1.rgb*b2) / (b1 + b2);
	return c;
}

fixed4 blend_terrain8Ex(v2f_terrain i)
{
	fixed depth = 0.45;
	fixed2 fduv = frac(i.uv.zw)*fixed2(0.25, 0.25);

	fixed2 uvb = i.uv.yx;
	fixed4 c = fixed4(0, 0, 0, 0);
	fixed4 c0 = fixed4(0, 0, 0, 0);
	fixed4 c1 = fixed4(0, 0, 0, 0);
	fixed4 b = tex2D(_Blend, uvb);
	fixed ma = 0;
	fixed b1 = 0;
	fixed b2 = 0;
#ifdef _DETal2
#ifdef _DETalTEX16
	fixed2 uv0 = fduv + fixed2(0, 0.5);
	fixed2 uv1 = fduv + fixed2(0.25, 0.5);
#else
	fixed2 uv0 = fduv + fixed2(0, 0.75);
	fixed2 uv1 = fduv + fixed2(0.25, 0.75);
#endif
	c0 = tex2D(_Detal, uv0);
	c1 = tex2D(_Detal, uv1);
	ma = max(c0.a + b.r, c1.a + b.g) - depth;

	b1 = max(c0.a + b.r - ma, 0);
	b2 = max(c1.a + b.g - ma, 0);

	c.rgb = (c0.rgb*b1 + c1.rgb*b2) / (b1 + b2);
	return c;
#endif


	fixed blendmax1 = 0;
	fixed blendmax2 = 0;
#ifdef _DETal8
	fixed4 db = tex2D(_DetalBlend, uvb);
	fixed blendv0 = ceil(b.r * 100) + 0.1;
	fixed blendv1 = ceil(b.g * 100) + 0.2;
	fixed blendv2 = ceil(b.b * 100) + 0.3;
	fixed blendv3 = ceil(b.a * 100) + 0.4;
	fixed blendv4 = ceil(db.r * 100) + 0.5;
	fixed blendv5 = ceil(db.g * 100) + 0.6;
	fixed blendv6 = ceil(db.b * 100) + 0.7;
	fixed blendv7 = ceil(db.a * 100) + 0.8;

	blendmax1 =  max(max(max(blendv0, blendv1), max(blendv2, blendv3)), max(max(blendv4, blendv5), max(blendv6, blendv7)));
	blendmax2 =  max(max(max((1 - step(0, blendv0 - blendmax1))*blendv0,
								  (1 - step(0,blendv1 -blendmax1))*blendv1), max(
								  (1 - step(0, blendv2-blendmax1))*blendv2,
							      (1 - step(0, blendv3-blendmax1))*blendv3)), max(max(
								  (1 - step(0, blendv4-blendmax1))*blendv4,
								  (1 - step(0, blendv5-blendmax1))*blendv5), max(
								  (1 - step(0, blendv6-blendmax1))*blendv6,
								  (1 - step(0, blendv7-blendmax1))*blendv7)));
#endif
#ifdef _DETal4
	fixed blendv0 = ceil(b.r * 100) + 0.1;
	fixed blendv1 = ceil(b.g * 100) + 0.2;
	fixed blendv2 = ceil(b.b * 100) + 0.3;
	fixed blendv3 = ceil(b.a * 100) + 0.4;

	blendmax1 = max(max(blendv0, blendv1), max(blendv2, blendv3));
	blendmax2 = max(max((1 - step(0, blendv0 - blendmax1))*blendv0,(1 - step(0, blendv1 - blendmax1))*blendv1),
						  max((1 - step(0, blendv2 - blendmax1))*blendv2,(1 - step(0, blendv3 - blendmax1))*blendv3));
#endif
	fixed blendtype1 = round((frac(blendmax1)) * 10) - 1;// round(frac(blendmax1) * 10) - 1;
	fixed blendtype2 = round((frac(blendmax2)) * 10) - 1;
	fixed coreArea = floor(i.sf.z + 0.5f);
	blendtype1 += 8 * coreArea;
	blendtype2 += 8 * coreArea;
	fixed blend1 = ceil(blendmax1)*0.01;
	fixed blend2 = ceil(blendmax2)*0.01;
	fixed2 uv;
	uv.x = fmod(blendtype1, 4) *0.25;
	uv.y = (3.0 - floor(blendtype1*0.25)) *0.25;
	c0 = tex2D(_Detal, fduv + uv);
	uv.x = fmod(blendtype2, 4) *0.25;
	uv.y = (3.0 - floor(blendtype2*0.25)) *0.25;
	c1 = tex2D(_Detal, fduv + uv);
	ma = max(c0.a + blend1, c1.a + blend2) - depth;
	b1 = max(c0.a + blend1 - ma, 0);
	b2 = max(c1.a + blend2 - ma, 0);
	c.rgb = (c0.rgb*b1 + c1.rgb*b2) / (b1 + b2);
	//fixed3 norm = UnpackNormal(tex2D(_NormalMap, fduv*fixed2(3, 3)));//
	//fixed nh = saturate(dot(normalize( _NormalLightDir),norm));
	//fixed3 spec = i.lightColor.rgb * pow(nh, 8)*2;

	////return fixed4(spec, 1);
	//c.rgb += c.rgb*spec;
	return c;
}

fixed4 blend_terrain8(v2f_terrain i)
{
	fixed depth = 0.45;
	fixed2 fduv = frac(i.uv.zw)*fixed2(0.25, 0.25);

	fixed2 uvb = i.uv.yx;
	fixed4 c = fixed4(1, 1, 1, 1);
	fixed4 b = tex2D(_Blend, uvb);
#ifdef _DETal2
#ifdef _DETalTEX16
	fixed2 uv0 = fduv + fixed2(0, 0.5);
	fixed2 uv1 = fduv + fixed2(0.25, 0.5);
#else
	fixed2 uv0 = fduv + fixed2(0, 0.75);
	fixed2 uv1 = fduv + fixed2(0.25, 0.75);
#endif
	fixed4 c0 = tex2D(_Detal, uv0);
	fixed4 c1 = tex2D(_Detal, uv1);
	fixed ma = max(c0.a + b.r, c1.a + b.g) - depth;

	fixed b1 = max(c0.a + b.r - ma, 0);
	fixed b2 = max(c1.a + b.g - ma, 0);

	c.rgb = (c0.rgb*b1 + c1.rgb*b2) / (b1 + b2 );
#endif
#ifdef _DETal4
#ifdef _DETalTEX16
	fixed2 uv0 = fduv + fixed2(0, 0.5);
	fixed2 uv1 = fduv + fixed2(0.25, 0.5);
	fixed2 uv2 = fduv + fixed2(0.5, 0.5);
	fixed2 uv3 = fduv + fixed2(0.75, 0.5);
#else
	fixed2 uv0 = fduv + fixed2(0, 0.75);
	fixed2 uv1 = fduv + fixed2(0.25, 0.75);
	fixed2 uv2 = fduv + fixed2(0.5, 0.75);
	fixed2 uv3 = fduv + fixed2(0.75, 0.75);
#endif
	fixed4 c0 = tex2D(_Detal, uv0);
	fixed4 c1 = tex2D(_Detal, uv1);
	fixed4 c2 = tex2D(_Detal, uv2);
	fixed4 c3 = tex2D(_Detal, uv3);
	fixed ma = max(max(c0.a + b.r, c1.a + b.g), max(c2.a + b.b, c3.a + b.a)) - depth;

	fixed b1 = max(c0.a + b.r - ma, 0);
	fixed b2 = max(c1.a + b.g - ma, 0);
	fixed b3 = max(c2.a + b.b - ma, 0);
	fixed b4 = max(c3.a + b.a - ma, 0);

	c.rgb = (c0.rgb*b1 + c1.rgb*b2 + c2.rgb*b3 + c3.rgb*b4) / (b1 + b2 + b3 + b4);
#endif
#ifdef _DETal8
	fixed4 db = tex2D(_DetalBlend, uvb);
#ifdef _DETalTEX16
	fixed2 uv0 = fduv + fixed2(0, 0.75);
	fixed2 uv1 = fduv + fixed2(0.25, 0.75);
	fixed2 uv2 = fduv + fixed2(0.5, 0.75);
	fixed2 uv3 = fduv + fixed2(0.75, 0.75);
	fixed2 uv4 = fduv + fixed2(0, 0.5);
	fixed2 uv5 = fduv + fixed2(0.25, 0.5);
	fixed2 uv6 = fduv + fixed2(0.5, 0.5);
	fixed2 uv7 = fduv + fixed2(0.75, 0.5);
#else
	fixed2 uv0 = fduv + fixed2(0, 0.5);
	fixed2 uv1 = fduv + fixed2(0.25, 0.5);
	fixed2 uv2 = fduv + fixed2(0.5, 0.5);
	fixed2 uv3 = fduv + fixed2(0.75, 0.5);
	fixed2 uv4 = fduv + fixed2(0, 0);
	fixed2 uv5 = fduv + fixed2(0.25, 0);
	fixed2 uv6 = fduv + fixed2(0.5, 0);
	fixed2 uv7 = fduv + fixed2(0.75, 0);
#endif
	fixed4 c0 = tex2D(_Detal, uv0);
	fixed4 c1 = tex2D(_Detal, uv1);
	fixed4 c2 = tex2D(_Detal, uv2);
	fixed4 c3 = tex2D(_Detal, uv3);
	fixed4 c4 = tex2D(_Detal, uv4);
	fixed4 c5 = tex2D(_Detal, uv5);
	fixed4 c6 = tex2D(_Detal, uv6);
	fixed4 c7 = tex2D(_Detal, uv7);
	fixed c0a = c0.a;
	fixed c1a = c1.a;
	fixed c2a = c2.a;
	fixed c3a = c3.a;
	fixed c4a = c4.a;
	fixed c5a = c5.a;
	fixed c6a = c6.a;
	fixed c7a = c7.a;
	fixed br = b.r;
	fixed bg = b.g;
	fixed bb = b.b;
	fixed ba = b.a;
	fixed dbr = db.r;
	fixed dbg = db.g;
	fixed dbb = db.b;
	fixed dba = db.a;

	fixed ma1 = max(max(c0a + br, c1a + bg), max(c2a + bb, c3a + ba));
	fixed ma2 = max(max(c4a + dbr, c5a + dbg), max(c6a + dbb, c7a + dba));
	fixed ma = max(ma1, ma2) - depth;
	fixed b1 = max(c0a + br - ma, 0);
	fixed b2 = max(c1a + bg - ma, 0);
	fixed b3 = max(c2a + bb - ma, 0);
	fixed b4 = max(c3a + ba - ma, 0);
	fixed b5 = max(c4a + dbr - ma, 0);
	fixed b6 = max(c5a + dbg - ma, 0);
	fixed b7 = max(c6a + dbb - ma, 0);
	fixed b8 = max(c7a + dba - ma, 0);
	c.rgb = (c0.rgb*b1 + c1.rgb*b2 + c2.rgb*b3 + c3.rgb*b4 + c4.rgb*b5 + c5.rgb*b6 + c6.rgb*b7 + c7.rgb*b8) / (b1 + b2 + b3 + b4 + b5 + b6 + b7 + b8);
#endif
	return c;
}


inline fixed4 frag_terrain(v2f_terrain i) :SV_Target
{
	//fixed x = IsInMainServerBorder(i.wpos);
	//return fixed4(x, x, x, x);
	fixed4 c = blend_terrain8Ex(i);
	c *= fixed4(i.lightColor, 1);

#ifdef _SELECT_ON
	c.rgb += c.rgb*(GetSelectFactor(i.wpos))*i.select;
#endif
//#ifdef _BORDER_ON
//	fixed4 border = GetBorderColor(i.wpos)*1.15;
//	c.rgb = c.rgb * (1 - border.a) + border.rgb * (border.a);
//#endif
	c *= i.sf.x;
	ConvertMainServerColor(i.wpos, c);
	ApplyFog(c, _FogColor.rgb, i.sf.y);
	return c;
}

inline fixed4 frag_terrain_sample(v2f_terrain_sample i) :SV_Target
{
	fixed4 c = tex2D(_Detal, i.uv);
	c *= _TerrainColor * 2;
	
	c *= fixed4(i.lightColor, 1);

#ifdef _SELECT_ON
	c.rgb += c.rgb*(GetSelectFactor(i.wpos))*i.select;
#endif
	ConvertMainServerColor(i.wpos, c);
	c.a = i.color.r;
	return c;
}

uniform sampler2D _WaterMainTex;
uniform float4 _WaterMainTex_ST;
uniform sampler2D _WaterNoiseTex;

uniform half4 _WaterSetting;
uniform half4 _WaterTwistSetting;
uniform half _WaterIndentity;
uniform fixed _SpecularIndentity;
uniform samplerCUBE _Cube;

struct v2f_terrain_water
{
	float4 pos:POSITION;
	float2 uv:TEXCOORD0;
	float4 wh:TEXCOORD1;
	float4 sf : TEXCOORD2;
	float3 wpos : TEXCOORD3;
	float3 wview : TexCOORD5;
	fixed3 lightColor : TEXCOORD6;
};

inline v2f_terrain_water vert_terrain_water(appdata_terrain v)
{
	v2f_terrain_water o;

	float4 wpos = mul(unity_ObjectToWorld, v.vertex);
	o.wpos = wpos.xyz;
	o.wview = normalize(WorldSpaceViewDir(v.vertex));

	o.sf = float4(0, 0, 0, 0);
	o.sf.y = CalculateFogFactor(v.vertex, _FogLineMax);
	o.wh = fixed4(0, 0, 0, 0);
	o.wh.x = (v.color.r) * max(0.1, _Displacement);
	o.sf.x = v.color.g;
	v.vertex.xyz = v.vertex.xyz + v.normal *(_WaterSetting.x - o.wh.x) -v.normal * _Displacement * IsInCoreArea(o.wpos);// *IsInCoreArea(o.wpos);//
	V_CW_TransformPoint(v.vertex);
	o.lightColor = ShadeVertexLights(v.vertex, v.normal);
	o.pos = UnityObjectToClipPos(v.vertex);
	o.uv = TRANSFORM_TEX(v.texcoord, _WaterMainTex);
	o.wh.y = (1 - min(1, (o.wh.x) / (_WaterSetting.x)))*_WaterIndentity;
	return o;
}

inline fixed4 frag_terrain_water(v2f_terrain_water i) :SV_Target
{
	fixed3 viewDirWS = (i.wview);
	fixed3 waveOffset =
			(tex2D(_WaterNoiseTex, i.uv.xy + fixed2(0, _Time.y * _WaterSetting.w)).rgb +
			tex2D(_WaterNoiseTex, i.uv.xy + fixed2(_Time.y * _WaterSetting.z, 0)).rgb) - 1;
	fixed2 ruv = float2(i.uv.x, 1 - i.uv.y) + waveOffset.xy * _WaterSetting.y;
	fixed4 water = tex2D(_WaterMainTex, ruv);
	water.a *= i.wh.y;

#ifdef WATER_SPEC_ON
	waveOffset.y = 1;
	waveOffset = normalize(waveOffset + fixed3(-0.5,0,-0.5));
	fixed nh = saturate(dot(waveOffset, normalize(viewDirWS)));
	fixed3 spec = i.lightColor.rgb * (pow(nh, 128)) * _SpecularIndentity; //
#endif
#ifdef WATER_REFL_ON
	fixed3 localCorrReflDirWS = LocalCorrect(viewDirWS, i.wpos);
	fixed4 reflColor = texCUBE(_Cube, localCorrReflDirWS);
#endif
	fixed4 c = water;

	c *= fixed4(i.lightColor, 1);
#ifdef WATER_REFL_ON
	c.rgb *= reflColor.rgb + water.rgb;
#else
	c.rgb *= water.rbg;
#endif
#ifdef WATER_SPEC_ON
	c.rgb += spec*c.a;
#endif
	ConvertMainServerColor(i.wpos, c);
	ApplyFog(c, _FogColor.rgb, i.sf.y);
return c;
}



uniform float _Deepness;
uniform float _ShadowHight;
uniform float3 _ShadowLightDir;
struct v2f_shadow
{
	float4 pos : SV_POSITION;
	fixed4 color : TEXCOORD1;
};

struct appdata_shadow
{
	float4 vertex : POSITION;
	float3 normal : NORMAL;
	fixed4 color : COLOR;
	float4 texcoord : TEXCOORD0;
};

inline v2f_shadow vert_shadow(appdata_shadow v)
{
	float4 vt = v.vertex;
	vt = mul(unity_ObjectToWorld, vt);
	vt.xz = vt.xz - (vt.y / _ShadowLightDir.y)*_ShadowLightDir.xz;
	vt.y = _ShadowHight;
	vt = mul(unity_WorldToObject, vt);
	v2f_shadow o;
	o.color = v.color;
	o.pos = UnityObjectToClipPos(vt);
	return o;
}

inline fixed2 TreeWave(fixed3 wpos,float f)
{
	return f* (cos(_Time.y)*sin(_Time.x)) * sin((wpos.x + wpos.z) / 5)*0.7;
}

inline fixed4 frag_shadow(v2f_shadow i) :COLOR
{
	clip(i.color.a - 0.5);
	return fixed4(_Deepness,_Deepness,_Deepness,1);
}

#endif 
