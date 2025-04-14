// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Shader created with Shader Forge v1.26 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.26;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:0,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:True,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:0,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:0,bdst:1,dpts:2,wrdp:True,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:False,igpj:False,qofs:0,qpre:1,rntp:1,fgom:True,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.2784314,fgcg:0.2784314,fgcb:0.2784314,fgca:1,fgde:0.01,fgrn:30,fgrf:150,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:6749,x:32719,y:32712,varname:node_6749,prsc:2|emission-9192-OUT,custl-2532-OUT,alpha-939-A;n:type:ShaderForge.SFN_LightVector,id:8257,x:30233,y:32630,varname:node_8257,prsc:2;n:type:ShaderForge.SFN_NormalVector,id:6650,x:30233,y:32913,prsc:2,pt:False;n:type:ShaderForge.SFN_Dot,id:5474,x:30444,y:32691,varname:node_5474,prsc:2,dt:1|A-8257-OUT,B-6650-OUT;n:type:ShaderForge.SFN_Tex2d,id:2960,x:31074,y:32673,ptovrint:False,ptlb:DiffuseRamp,ptin:_DiffuseRamp,varname:_DiffuseRamp,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:2,isnm:False|UVIN-4742-OUT;n:type:ShaderForge.SFN_Append,id:4742,x:30692,y:32673,varname:node_4742,prsc:2|A-5474-OUT,B-5474-OUT;n:type:ShaderForge.SFN_LightAttenuation,id:7648,x:30692,y:32796,varname:node_7648,prsc:2;n:type:ShaderForge.SFN_Dot,id:7467,x:30448,y:33074,varname:node_7467,prsc:2,dt:1|A-6650-OUT,B-6544-OUT;n:type:ShaderForge.SFN_Append,id:7523,x:30884,y:33064,varname:node_7523,prsc:2|A-7467-OUT,B-7467-OUT;n:type:ShaderForge.SFN_Add,id:348,x:31703,y:32800,varname:node_348,prsc:2|A-2535-OUT,B-8594-OUT;n:type:ShaderForge.SFN_Tex2d,id:9229,x:31078,y:33064,ptovrint:False,ptlb:SpecularRamp,ptin:_SpecularRamp,varname:_SpecularRamp,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-7523-OUT;n:type:ShaderForge.SFN_Tex2d,id:2925,x:29730,y:31739,ptovrint:False,ptlb:E01,ptin:_E01,varname:_E01,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Color,id:7332,x:31078,y:33306,ptovrint:False,ptlb:SpecularRamp_Color,ptin:_SpecularRamp_Color,varname:_SpecularRamp_Color,prsc:0,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_Multiply,id:8594,x:31421,y:33063,varname:node_8594,prsc:2|A-9229-RGB,B-7332-RGB;n:type:ShaderForge.SFN_Code,id:294,x:29853,y:31393,varname:node_294,prsc:2,code:ZgBsAG8AYQB0ADQAIABrACAAPQBmAGwAbwBhAHQANAAoADAALgAwACwALQAxAC4AMAAvADMALgAwACwAMgAuADAALwAzAC4AMAAsAC0AMQAuADAAKQA7AAoAZgBsAG8AYQB0ADQAIABwACAAPQBSAEcAQgAuAGcAPABSAEcAQgAuAGIAPwBmAGwAbwBhAHQANAAoAFIARwBCAC4AYgAsAFIARwBCAC4AZwAsAGsALgB3ACwAawAuAHoAKQA6AGYAbABvAGEAdAA0ACgAUgBHAEIALgBnAGIALABrAC4AeAB5ACkAOwAKAGYAbABvAGEAdAA0ACAAcQAgAD0AUgBHAEIALgByADwAcAAuAHgAIAAgAD8AZgBsAG8AYQB0ADQAKABwAC4AeAAsAHAALgB5ACwAcAAuAHcALABSAEcAQgAuAHIAKQA6AGYAbABvAGEAdAA0ACgAUgBHAEIALgByACwAcAAuAHkAegB4ACkAOwAKAGYAbABvAGEAdAAgAGQAIAA9AHEALgB4AC0AbQBpAG4AKABxAC4AdwAsAHEALgB5ACkAOwAKAGYAbABvAGEAdAAgAGUAPQAxAC4AMABlAC0AMQAwADsACgByAGUAdAB1AHIAbgAgAGYAbABvAGEAdAAzACgAYQBiAHMAKABxAC4AegArACgAcQAuAHcALQBxAC4AeQApAC8AKAA2AC4AMAAqAGQAKwBlACkAKQAsAGQALwAoAHEALgB4ACsAZQApACwAcQAuAHgAKQA7AA==,output:2,fname:RGBtoHSV,width:716,height:154,input:2,input_1_label:RGB|A-2925-RGB;n:type:ShaderForge.SFN_Code,id:8422,x:31356,y:31319,varname:node_8422,prsc:2,code:ZgBsAG8AYQB0ADQAIABrACAAPQAgAGYAbABvAGEAdAA0ACgAMQAuADAALAAyAC4AMAAvADMALgAwACwAMQAuADAALwAzAC4AMAAsADMALgAwACkAOwAKAGYAbABvAGEAdAAzACAAcAAgAD0AYQBiAHMAKABmAHIAYQBjACgASABTAFYALgB4AHgAeAArAGsALgB4AHkAegApACoANgAuADAALQBrAC4AdwB3AHcAKQA7AAoAcgBlAHQAdQByAG4AIABIAFMAVgAuAHoAKgBsAGUAcgBwACgAawAuAHgAeAB4ACwAYwBsAGEAbQBwACgAcAAtAGsALgB4AHgAeAAsADAALgAwACwAMQAuADAAKQAsAEgAUwBWAC4AeQApADsA,output:2,fname:HSVtoRGB,width:649,height:127,input:2,input_1_label:HSV|A-7006-OUT;n:type:ShaderForge.SFN_Add,id:6661,x:30848,y:31143,varname:node_6661,prsc:2|A-4029-X,B-7729-R;n:type:ShaderForge.SFN_Vector4Property,id:4029,x:30637,y:31242,ptovrint:False,ptlb:HSV,ptin:_HSV,varname:_HSV,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1,v2:1,v3:1,v4:0;n:type:ShaderForge.SFN_Append,id:7006,x:31185,y:31319,varname:node_7006,prsc:2|A-5444-OUT,B-6726-OUT;n:type:ShaderForge.SFN_Append,id:5444,x:31018,y:31319,varname:node_5444,prsc:2|A-6661-OUT,B-6068-OUT;n:type:ShaderForge.SFN_Multiply,id:6068,x:30848,y:31281,varname:node_6068,prsc:2|A-4029-Y,B-7729-G;n:type:ShaderForge.SFN_Multiply,id:6726,x:30848,y:31413,varname:node_6726,prsc:2|A-4029-Z,B-7729-B;n:type:ShaderForge.SFN_ComponentMask,id:7729,x:30637,y:31392,varname:node_7729,prsc:2,cc1:0,cc2:1,cc3:2,cc4:-1|IN-294-OUT;n:type:ShaderForge.SFN_Power,id:582,x:31670,y:31693,varname:node_582,prsc:2|VAL-8422-OUT,EXP-560-OUT;n:type:ShaderForge.SFN_ValueProperty,id:560,x:31509,y:31795,ptovrint:False,ptlb:E01_Power,ptin:_E01_Power,varname:_E01_Power,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Fresnel,id:5372,x:30617,y:32298,varname:node_5372,prsc:2|EXP-4182-OUT;n:type:ShaderForge.SFN_Multiply,id:1596,x:31509,y:32202,varname:node_1596,prsc:2|A-5560-RGB,B-2355-OUT;n:type:ShaderForge.SFN_Color,id:5560,x:31322,y:32094,ptovrint:False,ptlb:Glow_Color,ptin:_Glow_Color,varname:_Glow_Color,prsc:0,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_OneMinus,id:5202,x:30812,y:32298,varname:node_5202,prsc:2|IN-5372-OUT;n:type:ShaderForge.SFN_RemapRange,id:8127,x:30978,y:32298,varname:node_8127,prsc:2,frmn:0,frmx:1,tomn:-0.3,tomx:1|IN-5202-OUT;n:type:ShaderForge.SFN_Slider,id:4182,x:30290,y:32325,ptovrint:False,ptlb:Glow_Power,ptin:_Glow_Power,varname:_Glow_Power,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:1;n:type:ShaderForge.SFN_Vector1,id:6799,x:31005,y:32476,varname:node_6799,prsc:2,v1:0.5;n:type:ShaderForge.SFN_Min,id:5285,x:31158,y:32298,varname:node_5285,prsc:2|A-8127-OUT,B-6799-OUT;n:type:ShaderForge.SFN_Clamp01,id:2355,x:31333,y:32298,varname:node_2355,prsc:2|IN-5285-OUT;n:type:ShaderForge.SFN_Fresnel,id:7849,x:31051,y:33549,varname:node_7849,prsc:2|EXP-8461-OUT;n:type:ShaderForge.SFN_Add,id:2532,x:32427,y:32764,varname:node_2532,prsc:2|A-676-OUT,B-5325-OUT;n:type:ShaderForge.SFN_Slider,id:8461,x:30703,y:33569,ptovrint:False,ptlb:Rim_Power,ptin:_Rim_Power,varname:_Rim_Power,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:1,cur:0.7,max:0.3;n:type:ShaderForge.SFN_RemapRange,id:765,x:31220,y:33548,varname:node_765,prsc:2,frmn:0,frmx:1,tomn:-4,tomx:2|IN-7849-OUT;n:type:ShaderForge.SFN_Clamp01,id:8342,x:31394,y:33548,varname:node_8342,prsc:2|IN-765-OUT;n:type:ShaderForge.SFN_Color,id:9555,x:31406,y:33398,ptovrint:False,ptlb:Rim_Color,ptin:_Rim_Color,varname:_Rim_Color,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0,c2:0,c3:0,c4:1;n:type:ShaderForge.SFN_Multiply,id:5325,x:31613,y:33527,varname:node_5325,prsc:2|A-9555-RGB,B-8342-OUT;n:type:ShaderForge.SFN_VertexColor,id:939,x:32390,y:32918,varname:node_939,prsc:2;n:type:ShaderForge.SFN_LightColor,id:2462,x:31398,y:32539,varname:node_2462,prsc:2;n:type:ShaderForge.SFN_Multiply,id:6716,x:30862,y:32709,varname:node_6716,prsc:2|A-4742-OUT,B-7648-OUT;n:type:ShaderForge.SFN_Multiply,id:2535,x:31553,y:32628,varname:node_2535,prsc:2|A-2462-RGB,B-8515-OUT;n:type:ShaderForge.SFN_Multiply,id:4015,x:31927,y:32778,varname:node_4015,prsc:2|A-582-OUT,B-348-OUT;n:type:ShaderForge.SFN_Add,id:676,x:32163,y:32761,varname:node_676,prsc:2|A-1596-OUT,B-4015-OUT;n:type:ShaderForge.SFN_HalfVector,id:6544,x:30242,y:33215,varname:node_6544,prsc:2;n:type:ShaderForge.SFN_Add,id:2102,x:31242,y:32673,varname:node_2102,prsc:2|A-2960-RGB,B-4216-OUT;n:type:ShaderForge.SFN_Clamp01,id:8515,x:31398,y:32673,varname:node_8515,prsc:2|IN-2102-OUT;n:type:ShaderForge.SFN_Slider,id:4216,x:30933,y:32871,ptovrint:False,ptlb:shadow_Bright,ptin:_shadow_Bright,varname:_shadow_Bright,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:1;n:type:ShaderForge.SFN_Tex2d,id:4286,x:32543,y:32222,ptovrint:False,ptlb:_Emission,ptin:__Emission,varname:__Emission,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False|UVIN-8194-UVOUT;n:type:ShaderForge.SFN_Panner,id:8194,x:32372,y:32222,varname:node_8194,prsc:2,spu:1,spv:1|UVIN-4554-UVOUT,DIST-6856-OUT;n:type:ShaderForge.SFN_TexCoord,id:4554,x:32207,y:32098,varname:node_4554,prsc:2,uv:0;n:type:ShaderForge.SFN_Multiply,id:6856,x:32207,y:32259,varname:node_6856,prsc:2|A-5265-T,B-5842-OUT;n:type:ShaderForge.SFN_Time,id:5265,x:31947,y:32138,varname:node_5265,prsc:2;n:type:ShaderForge.SFN_ValueProperty,id:5842,x:31947,y:32328,ptovrint:False,ptlb:_Emission_UVYSpeed,ptin:__Emission_UVYSpeed,varname:__Emission_UVYSpeed,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:9192,x:32654,y:32480,varname:node_9192,prsc:2|A-4286-RGB,B-5234-RGB;n:type:ShaderForge.SFN_Color,id:5234,x:32413,y:32550,ptovrint:False,ptlb:_Emission_Color,ptin:__Emission_Color,varname:__Emission_Color,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;proporder:560-2925-4286-5234-5842-4029-2960-4216-9229-7332-5560-4182-9555-8461;pass:END;sub:END;*/

Shader "yh/Toon_CustomLighting" {
    Properties {
        _E01_Power ("E01_Power", Float ) = 1
        _E01 ("E01", 2D) = "white" {}
        __Emission ("_Emission", 2D) = "white" {}
        __Emission_Color ("_Emission_Color", Color) = (1,1,1,1)
        __Emission_UVYSpeed ("_Emission_UVYSpeed", Float ) = 0
        _HSV ("HSV", Vector) = (1,1,1,0)
        _DiffuseRamp ("DiffuseRamp", 2D) = "black" {}
        _shadow_Bright ("shadow_Bright", Range(0, 1)) = 0
        _SpecularRamp ("SpecularRamp", 2D) = "white" {}
        _SpecularRamp_Color ("SpecularRamp_Color", Color) = (1,1,1,1)
        _Glow_Color ("Glow_Color", Color) = (1,1,1,1)
        _Glow_Power ("Glow_Power", Range(0, 1)) = 0
        _Rim_Color ("Rim_Color", Color) = (0,0,0,1)
        _Rim_Power ("Rim_Power", Range(1, 0.3)) = 0.7
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile_fog
            #pragma exclude_renderers xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
            uniform float4 _LightColor0;
            uniform float4 _TimeEditor;
            uniform sampler2D _DiffuseRamp; uniform float4 _DiffuseRamp_ST;
            uniform sampler2D _SpecularRamp; uniform float4 _SpecularRamp_ST;
            uniform sampler2D _E01; uniform float4 _E01_ST;
            uniform fixed4 _SpecularRamp_Color;
            float3 RGBtoHSV( float3 RGB ){
            float4 k =float4(0.0,-1.0/3.0,2.0/3.0,-1.0);
            float4 p =RGB.g<RGB.b?float4(RGB.b,RGB.g,k.w,k.z):float4(RGB.gb,k.xy);
            float4 q =RGB.r<p.x  ?float4(p.x,p.y,p.w,RGB.r):float4(RGB.r,p.yzx);
            float d =q.x-min(q.w,q.y);
            float e=1.0e-10;
            return float3(abs(q.z+(q.w-q.y)/(6.0*d+e)),d/(q.x+e),q.x);
            }
            
            float3 HSVtoRGB( float3 HSV ){
            float4 k = float4(1.0,2.0/3.0,1.0/3.0,3.0);
            float3 p =abs(frac(HSV.xxx+k.xyz)*6.0-k.www);
            return HSV.z*lerp(k.xxx,clamp(p-k.xxx,0.0,1.0),HSV.y);
            }
            
            uniform float4 _HSV;
            uniform float _E01_Power;
            uniform fixed4 _Glow_Color;
            uniform float _Glow_Power;
            uniform half _Rim_Power;
            uniform float4 _Rim_Color;
            uniform float _shadow_Bright;
            uniform sampler2D __Emission; uniform float4 __Emission_ST;
            uniform float __Emission_UVYSpeed;
            uniform float4 __Emission_Color;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float4 vertexColor : COLOR;
                LIGHTING_COORDS(3,4)
                UNITY_FOG_COORDS(5)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos(v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);
////// Lighting:
////// Emissive:
                float4 node_5265 = _Time + _TimeEditor;
                float2 node_8194 = (i.uv0+(node_5265.g*__Emission_UVYSpeed)*float2(1,1));
                float4 __Emission_var = tex2D(__Emission,TRANSFORM_TEX(node_8194, __Emission));
                float3 emissive = (__Emission_var.rgb*__Emission_Color.rgb);
                half4 _E01_var = tex2D(_E01,TRANSFORM_TEX(i.uv0, _E01));
                float3 node_7729 = RGBtoHSV( _E01_var.rgb ).rgb;
                float node_5474 = max(0,dot(lightDirection,i.normalDir));
                float2 node_4742 = float2(node_5474,node_5474);
                half4 _DiffuseRamp_var = tex2D(_DiffuseRamp,TRANSFORM_TEX(node_4742, _DiffuseRamp));
                float node_7467 = max(0,dot(i.normalDir,halfDirection));
                float2 node_7523 = float2(node_7467,node_7467);
                half4 _SpecularRamp_var = tex2D(_SpecularRamp,TRANSFORM_TEX(node_7523, _SpecularRamp));
                float3 finalColor = emissive + (((_Glow_Color.rgb*saturate(min(((1.0 - pow(1.0-max(0,dot(normalDirection, viewDirection)),_Glow_Power))*1.3+-0.3),0.5)))+(pow(HSVtoRGB( float3(float2((_HSV.r+node_7729.r),(_HSV.g*node_7729.g)),(_HSV.b*node_7729.b)) ),_E01_Power)*((_LightColor0.rgb*saturate((_DiffuseRamp_var.rgb+_shadow_Bright)))+(_SpecularRamp_var.rgb*_SpecularRamp_Color.rgb))))+(_Rim_Color.rgb*saturate((pow(1.0-max(0,dot(normalDirection, viewDirection)),_Rim_Power)*6.0+-4.0))));
                fixed4 finalRGBA = fixed4(finalColor,i.vertexColor.a);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
