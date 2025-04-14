// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Shader created with Shader Forge v1.26 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.26;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:1,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:0,bdst:1,dpts:2,wrdp:True,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:False,qofs:0,qpre:1,rntp:1,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.0710424,fgcg:0.344052,fgcb:0.5367647,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:4013,x:32836,y:32776,varname:node_4013,prsc:2|diff-563-OUT,emission-6938-OUT;n:type:ShaderForge.SFN_Tex2d,id:4820,x:31950,y:32546,ptovrint:False,ptlb:node_4820,ptin:_node_4820,varname:node_4820,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:991856d13e442a547943060d05f6ad15,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:563,x:32487,y:32595,varname:node_563,prsc:2|A-4820-RGB,B-2735-OUT;n:type:ShaderForge.SFN_Tex2d,id:9955,x:31474,y:32938,ptovrint:False,ptlb:node_9955,ptin:_node_9955,varname:node_9955,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:98bc2017a7aad21419629e57bf0e0d1a,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Vector3,id:3247,x:31808,y:33130,varname:node_3247,prsc:2,v1:1,v2:0.2461035,v3:0;n:type:ShaderForge.SFN_Multiply,id:3489,x:32207,y:33111,varname:node_3489,prsc:2|A-6867-OUT,B-3247-OUT,C-1677-OUT;n:type:ShaderForge.SFN_Power,id:6867,x:31785,y:32944,varname:node_6867,prsc:2|VAL-9955-RGB,EXP-6616-OUT;n:type:ShaderForge.SFN_Vector1,id:6616,x:31603,y:33146,varname:node_6616,prsc:2,v1:1;n:type:ShaderForge.SFN_Panner,id:7880,x:31824,y:33565,varname:node_7880,prsc:2,spu:0.02,spv:0.02|UVIN-5367-UVOUT;n:type:ShaderForge.SFN_TexCoord,id:5367,x:31577,y:33565,varname:node_5367,prsc:2,uv:0;n:type:ShaderForge.SFN_Vector1,id:1677,x:31865,y:33250,varname:node_1677,prsc:2,v1:1.5;n:type:ShaderForge.SFN_Multiply,id:6393,x:32339,y:33473,varname:node_6393,prsc:2|A-3489-OUT,B-8607-OUT,C-9969-RGB;n:type:ShaderForge.SFN_Tex2d,id:9969,x:31851,y:33344,ptovrint:False,ptlb:node_9969,ptin:_node_9969,varname:node_9969,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:cb35c878437c08a4b9109fa7ff7f94d8,ntxv:0,isnm:False|UVIN-7880-UVOUT;n:type:ShaderForge.SFN_Color,id:8931,x:31950,y:32801,ptovrint:False,ptlb:node_8931,ptin:_node_8931,varname:node_8931,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_Time,id:1757,x:31379,y:33868,varname:node_1757,prsc:2;n:type:ShaderForge.SFN_Sin,id:6844,x:31614,y:33868,varname:node_6844,prsc:2|IN-1757-T;n:type:ShaderForge.SFN_Add,id:8607,x:31876,y:33884,varname:node_8607,prsc:2|A-6844-OUT,B-1956-OUT;n:type:ShaderForge.SFN_Vector1,id:1956,x:31595,y:34186,varname:node_1956,prsc:2,v1:1.2;n:type:ShaderForge.SFN_Multiply,id:9493,x:32522,y:33596,varname:node_9493,prsc:2|A-6393-OUT,B-2776-RGB;n:type:ShaderForge.SFN_VertexColor,id:2776,x:32291,y:33789,varname:node_2776,prsc:2;n:type:ShaderForge.SFN_Multiply,id:6938,x:32808,y:33656,varname:node_6938,prsc:2|A-9493-OUT,B-7013-OUT;n:type:ShaderForge.SFN_Slider,id:7013,x:32583,y:33827,ptovrint:False,ptlb:node_7013,ptin:_node_7013,varname:node_7013,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:1;n:type:ShaderForge.SFN_Multiply,id:2735,x:32255,y:32762,varname:node_2735,prsc:2|A-8931-RGB,B-4801-OUT;n:type:ShaderForge.SFN_Slider,id:4801,x:32212,y:33010,ptovrint:False,ptlb:node_4801,ptin:_node_4801,varname:node_4801,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:1;proporder:4820-9955-9969-8931-7013-4801;pass:END;sub:END;*/

Shader "Shader Forge/aaaa2" {
    Properties {
        _node_4820 ("node_4820", 2D) = "white" {}
        _node_9955 ("node_9955", 2D) = "white" {}
        _node_9969 ("node_9969", 2D) = "white" {}
        _node_8931 ("node_8931", Color) = (1,1,1,1)
        _node_7013 ("node_7013", Range(0, 1)) = 1
        _node_4801 ("node_4801", Range(0, 1)) = 1
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
            #pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
            uniform float4 _LightColor0;
            uniform float4 _TimeEditor;
            uniform sampler2D _node_4820; uniform float4 _node_4820_ST;
            uniform sampler2D _node_9955; uniform float4 _node_9955_ST;
            uniform sampler2D _node_9969; uniform float4 _node_9969_ST;
            uniform float4 _node_8931;
            uniform float _node_7013;
            uniform float _node_4801;
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
                i.normalDir = normalize(i.normalDir);
                float3 normalDirection = i.normalDir;
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
                float4 _node_4820_var = tex2D(_node_4820,TRANSFORM_TEX(i.uv0, _node_4820));
                float3 diffuseColor = (_node_4820_var.rgb*(_node_8931.rgb*_node_4801));
                float3 diffuse = (directDiffuse + indirectDiffuse) * diffuseColor;
////// Emissive:
                float4 _node_9955_var = tex2D(_node_9955,TRANSFORM_TEX(i.uv0, _node_9955));
                float4 node_1757 = _Time + _TimeEditor;
                float4 node_957 = _Time + _TimeEditor;
                float2 node_7880 = (i.uv0+node_957.g*float2(0.02,0.02));
                float4 _node_9969_var = tex2D(_node_9969,TRANSFORM_TEX(node_7880, _node_9969));
                float3 emissive = ((((pow(_node_9955_var.rgb,1.0)*float3(1,0.2461035,0)*1.5)*(sin(node_1757.g)+1.2)*_node_9969_var.rgb)*i.vertexColor.rgb)*_node_7013);
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
            #pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
            uniform float4 _LightColor0;
            uniform float4 _TimeEditor;
            uniform sampler2D _node_4820; uniform float4 _node_4820_ST;
            uniform sampler2D _node_9955; uniform float4 _node_9955_ST;
            uniform sampler2D _node_9969; uniform float4 _node_9969_ST;
            uniform float4 _node_8931;
            uniform float _node_7013;
            uniform float _node_4801;
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
                i.normalDir = normalize(i.normalDir);
                float3 normalDirection = i.normalDir;
                float3 lightDirection = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz,_WorldSpaceLightPos0.w));
                float3 lightColor = _LightColor0.rgb;
////// Lighting:
                float attenuation = LIGHT_ATTENUATION(i);
                float3 attenColor = attenuation * _LightColor0.xyz;
/////// Diffuse:
                float NdotL = max(0.0,dot( normalDirection, lightDirection ));
                float3 directDiffuse = max( 0.0, NdotL) * attenColor;
                float4 _node_4820_var = tex2D(_node_4820,TRANSFORM_TEX(i.uv0, _node_4820));
                float3 diffuseColor = (_node_4820_var.rgb*(_node_8931.rgb*_node_4801));
                float3 diffuse = directDiffuse * diffuseColor;
/// Final Color:
                float3 finalColor = diffuse;
                fixed4 finalRGBA = fixed4(finalColor * 1,0);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
