// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Shader created with Shader Forge v1.26 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.26;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:1,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:0,bdst:1,dpts:2,wrdp:True,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:False,qofs:0,qpre:2,rntp:3,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:4013,x:33266,y:32142,varname:node_4013,prsc:2|diff-7592-RGB,emission-5412-RGB,clip-5677-OUT;n:type:ShaderForge.SFN_Slider,id:287,x:31229,y:32656,ptovrint:False,ptlb:shuchu,ptin:_shuchu,varname:node_287,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.4516637,max:1;n:type:ShaderForge.SFN_Tex2d,id:9676,x:31761,y:32884,ptovrint:False,ptlb:node_9676,ptin:_node_9676,varname:node_9676,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:28c7aad1372ff114b90d330f8a2dd938,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Add,id:5677,x:32040,y:32757,varname:node_5677,prsc:2|A-2702-OUT,B-9676-R;n:type:ShaderForge.SFN_RemapRange,id:2702,x:31761,y:32655,varname:node_2702,prsc:2,frmn:0,frmx:1,tomn:-0.7,tomx:0.7|IN-7990-OUT;n:type:ShaderForge.SFN_OneMinus,id:7990,x:31571,y:32655,varname:node_7990,prsc:2|IN-287-OUT;n:type:ShaderForge.SFN_RemapRange,id:7108,x:32063,y:32434,varname:node_7108,prsc:2,frmn:0,frmx:1,tomn:-1,tomx:2.5|IN-5677-OUT;n:type:ShaderForge.SFN_Clamp01,id:3436,x:32280,y:32434,varname:node_3436,prsc:2|IN-7108-OUT;n:type:ShaderForge.SFN_Append,id:3153,x:32553,y:32188,varname:node_3153,prsc:2|A-6335-OUT,B-4243-OUT;n:type:ShaderForge.SFN_Vector1,id:4243,x:32486,y:32345,varname:node_4243,prsc:2,v1:0;n:type:ShaderForge.SFN_Tex2d,id:7592,x:32804,y:31997,ptovrint:False,ptlb:node_7592,ptin:_node_7592,varname:node_7592,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:991856d13e442a547943060d05f6ad15,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:5412,x:32863,y:32191,varname:node_5412,prsc:2,tex:271f5ee3273dd7f4fae6e204d4f8c4bf,ntxv:0,isnm:False|UVIN-3153-OUT,TEX-2537-TEX;n:type:ShaderForge.SFN_Tex2dAsset,id:2537,x:32486,y:32471,ptovrint:False,ptlb:node_2537,ptin:_node_2537,varname:node_2537,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:271f5ee3273dd7f4fae6e204d4f8c4bf,ntxv:0,isnm:False;n:type:ShaderForge.SFN_OneMinus,id:6335,x:32323,y:32188,varname:node_6335,prsc:2|IN-3436-OUT;proporder:9676-287-2537-7592;pass:END;sub:END;*/

Shader "Shader Forge/rongjie" {
    Properties {
        _node_9676 ("node_9676", 2D) = "white" {}
        _shuchu ("shuchu", Range(0, 1)) = 0.4516637
        _node_2537 ("node_2537", 2D) = "white" {}
        _node_7592 ("node_7592", 2D) = "white" {}
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
            #include "AutoLight.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile_fog
            #pragma exclude_renderers d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
            uniform float4 _LightColor0;
            uniform float _shuchu;
            uniform sampler2D _node_9676; uniform float4 _node_9676_ST;
            uniform sampler2D _node_7592; uniform float4 _node_7592_ST;
            uniform sampler2D _node_2537; uniform float4 _node_2537_ST;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                LIGHTING_COORDS(3,4)
                UNITY_FOG_COORDS(5)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos(v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3 normalDirection = i.normalDir;
                float4 _node_9676_var = tex2D(_node_9676,TRANSFORM_TEX(i.uv0, _node_9676));
                float node_5677 = (((1.0 - _shuchu)*1.4+-0.7)+_node_9676_var.r);
                clip(node_5677 - 0.5);
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;
////// Lighting:
                float attenuation = LIGHT_ATTENUATION(i);
                float3 attenColor = attenuation * _LightColor0.xyz;
/////// Diffuse:
                float NdotL = max(0.0,dot( normalDirection, lightDirection ));
                float3 directDiffuse = max( 0.0, NdotL) * attenColor;
                float3 indirectDiffuse = float3(0,0,0);
                indirectDiffuse += UNITY_LIGHTMODEL_AMBIENT.rgb; // Ambient Light
                float4 _node_7592_var = tex2D(_node_7592,TRANSFORM_TEX(i.uv0, _node_7592));
                float3 diffuseColor = _node_7592_var.rgb;
                float3 diffuse = (directDiffuse + indirectDiffuse) * diffuseColor;
////// Emissive:
                float2 node_3153 = float2((1.0 - saturate((node_5677*3.5+-1.0))),0.0);
                float4 node_5412 = tex2D(_node_2537,TRANSFORM_TEX(node_3153, _node_2537));
                float3 emissive = node_5412.rgb;
/// Final Color:
                float3 finalColor = diffuse + emissive;
                fixed4 finalRGBA = fixed4(finalColor,1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
        Pass {
            Name "FORWARD_DELTA"
            Tags {
                "LightMode"="ForwardAdd"
            }
            Blend One One
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDADD
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #pragma multi_compile_fwdadd_fullshadows
            #pragma multi_compile_fog
            #pragma exclude_renderers d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
            uniform float4 _LightColor0;
            uniform float _shuchu;
            uniform sampler2D _node_9676; uniform float4 _node_9676_ST;
            uniform sampler2D _node_7592; uniform float4 _node_7592_ST;
            uniform sampler2D _node_2537; uniform float4 _node_2537_ST;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                LIGHTING_COORDS(3,4)
                UNITY_FOG_COORDS(5)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos(v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3 normalDirection = i.normalDir;
                float4 _node_9676_var = tex2D(_node_9676,TRANSFORM_TEX(i.uv0, _node_9676));
                float node_5677 = (((1.0 - _shuchu)*1.4+-0.7)+_node_9676_var.r);
                clip(node_5677 - 0.5);
                float3 lightDirection = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz,_WorldSpaceLightPos0.w));
                float3 lightColor = _LightColor0.rgb;
////// Lighting:
                float attenuation = LIGHT_ATTENUATION(i);
                float3 attenColor = attenuation * _LightColor0.xyz;
/////// Diffuse:
                float NdotL = max(0.0,dot( normalDirection, lightDirection ));
                float3 directDiffuse = max( 0.0, NdotL) * attenColor;
                float4 _node_7592_var = tex2D(_node_7592,TRANSFORM_TEX(i.uv0, _node_7592));
                float3 diffuseColor = _node_7592_var.rgb;
                float3 diffuse = directDiffuse * diffuseColor;
/// Final Color:
                float3 finalColor = diffuse;
                fixed4 finalRGBA = fixed4(finalColor * 1,0);
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
            #pragma exclude_renderers d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
            uniform float _shuchu;
            uniform sampler2D _node_9676; uniform float4 _node_9676_ST;
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
                float4 _node_9676_var = tex2D(_node_9676,TRANSFORM_TEX(i.uv0, _node_9676));
                float node_5677 = (((1.0 - _shuchu)*1.4+-0.7)+_node_9676_var.r);
                clip(node_5677 - 0.5);
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
