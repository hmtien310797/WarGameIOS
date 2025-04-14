// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Shader created with Shader Forge v1.26 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.26;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:0,bdst:1,dpts:2,wrdp:True,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:False,qofs:0,qpre:2,rntp:3,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:4013,x:33266,y:32142,varname:node_4013,prsc:2|emission-2310-OUT,custl-7592-RGB,clip-8601-OUT;n:type:ShaderForge.SFN_Slider,id:287,x:31229,y:32656,ptovrint:False,ptlb:shuchu,ptin:_shuchu,varname:node_287,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:1;n:type:ShaderForge.SFN_Tex2d,id:9676,x:31761,y:32884,ptovrint:False,ptlb:zaobo,ptin:_zaobo,varname:node_9676,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:28c7aad1372ff114b90d330f8a2dd938,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Add,id:5677,x:32040,y:32757,varname:node_5677,prsc:2|A-2702-OUT,B-9676-R;n:type:ShaderForge.SFN_RemapRange,id:2702,x:31761,y:32655,varname:node_2702,prsc:2,frmn:0,frmx:1,tomn:-0.7,tomx:0.7|IN-7990-OUT;n:type:ShaderForge.SFN_OneMinus,id:7990,x:31571,y:32655,varname:node_7990,prsc:2|IN-287-OUT;n:type:ShaderForge.SFN_RemapRange,id:7108,x:32063,y:32434,varname:node_7108,prsc:2,frmn:0,frmx:1,tomn:-1,tomx:2.5|IN-5677-OUT;n:type:ShaderForge.SFN_Clamp01,id:3436,x:32280,y:32434,varname:node_3436,prsc:2|IN-7108-OUT;n:type:ShaderForge.SFN_Append,id:3153,x:32553,y:32188,varname:node_3153,prsc:2|A-6335-OUT,B-4243-OUT;n:type:ShaderForge.SFN_Vector1,id:4243,x:32486,y:32345,varname:node_4243,prsc:2,v1:0;n:type:ShaderForge.SFN_Tex2d,id:7592,x:32804,y:31997,ptovrint:False,ptlb:d,ptin:_d,varname:node_7592,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:991856d13e442a547943060d05f6ad15,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:5412,x:32863,y:32191,varname:node_5412,prsc:2,tex:271f5ee3273dd7f4fae6e204d4f8c4bf,ntxv:0,isnm:False|UVIN-3153-OUT,TEX-2537-TEX;n:type:ShaderForge.SFN_Tex2dAsset,id:2537,x:32486,y:32471,ptovrint:False,ptlb:jianbian,ptin:_jianbian,varname:node_2537,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:271f5ee3273dd7f4fae6e204d4f8c4bf,ntxv:0,isnm:False;n:type:ShaderForge.SFN_OneMinus,id:6335,x:32323,y:32188,varname:node_6335,prsc:2|IN-3436-OUT;n:type:ShaderForge.SFN_Multiply,id:2310,x:32874,y:32360,varname:node_2310,prsc:2|A-5412-RGB,B-6335-OUT,C-7486-OUT;n:type:ShaderForge.SFN_Vector1,id:7486,x:32880,y:32753,varname:node_7486,prsc:2,v1:5;n:type:ShaderForge.SFN_Multiply,id:8601,x:33149,y:32677,varname:node_8601,prsc:2|A-7592-A,B-5677-OUT;proporder:9676-287-2537-7592;pass:END;sub:END;*/

Shader "Shader Forge/rongjieFix" {
    Properties {
        _zaobo ("zaobo", 2D) = "white" {}
        _shuchu ("shuchu", Range(0, 1)) = 0
        _jianbian ("jianbian", 2D) = "white" {}
        _d ("d", 2D) = "white" {}
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "Queue"="AlphaTest"
            "RenderType"="TransparentCutout"
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
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile_fog
            #pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
            uniform float _shuchu;
            uniform sampler2D _zaobo; uniform float4 _zaobo_ST;
            uniform sampler2D _d; uniform float4 _d_ST;
            uniform sampler2D _jianbian; uniform float4 _jianbian_ST;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                UNITY_FOG_COORDS(1)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.pos = UnityObjectToClipPos(v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                float4 _d_var = tex2D(_d,TRANSFORM_TEX(i.uv0, _d));
                float4 _zaobo_var = tex2D(_zaobo,TRANSFORM_TEX(i.uv0, _zaobo));
                float node_5677 = (((1.0 - _shuchu)*1.4+-0.7)+_zaobo_var.r);
                clip((_d_var.a*node_5677) - 0.5);
////// Lighting:
////// Emissive:
                float node_6335 = (1.0 - saturate((node_5677*3.5+-1.0)));
                float2 node_3153 = float2(node_6335,0.0);
                float4 node_5412 = tex2D(_jianbian,TRANSFORM_TEX(node_3153, _jianbian));
                float3 emissive = (node_5412.rgb*node_6335*5.0);
                float3 finalColor = emissive + _d_var.rgb;
                fixed4 finalRGBA = fixed4(finalColor,1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
        Pass {
            Name "ShadowCaster"
            Tags {
                "LightMode"="ShadowCaster"
            }
            Offset 1, 1
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_SHADOWCASTER
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma multi_compile_fog
            #pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
            uniform float _shuchu;
            uniform sampler2D _zaobo; uniform float4 _zaobo_ST;
            uniform sampler2D _d; uniform float4 _d_ST;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                V2F_SHADOW_CASTER;
                float2 uv0 : TEXCOORD1;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.pos = UnityObjectToClipPos(v.vertex );
                TRANSFER_SHADOW_CASTER(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                float4 _d_var = tex2D(_d,TRANSFORM_TEX(i.uv0, _d));
                float4 _zaobo_var = tex2D(_zaobo,TRANSFORM_TEX(i.uv0, _zaobo));
                float node_5677 = (((1.0 - _shuchu)*1.4+-0.7)+_zaobo_var.r);
                clip((_d_var.a*node_5677) - 0.5);
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
