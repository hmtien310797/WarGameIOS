// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Shader created with Shader Forge v1.26 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.26;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:0,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:False,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:False,igpj:False,qofs:-1,qpre:3,rntp:2,fgom:True,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0,fgcg:0,fgcb:0,fgca:1,fgde:0.005,fgrn:20,fgrf:80,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:1,x:34630,y:32549,varname:node_1,prsc:2|emission-850-OUT,custl-9357-OUT,alpha-9084-OUT;n:type:ShaderForge.SFN_Tex2d,id:2,x:32708,y:31091,ptovrint:False,ptlb:E01_wave01,ptin:_E01_wave01,varname:_E01_wave01,prsc:0,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:6d18dc0813cd61f4781b983c46b4ac19,ntxv:0,isnm:False|UVIN-1263-OUT;n:type:ShaderForge.SFN_Color,id:3,x:33153,y:30947,ptovrint:True,ptlb:E01_Color,ptin:_E01_Color,varname:_E01_Color,prsc:0,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_Multiply,id:4,x:33307,y:31088,varname:node_4,prsc:2|A-3-RGB,B-1822-OUT;n:type:ShaderForge.SFN_Fresnel,id:94,x:32600,y:31977,varname:node_94,prsc:2|EXP-98-OUT;n:type:ShaderForge.SFN_ValueProperty,id:98,x:32417,y:32022,ptovrint:False,ptlb:RimPower,ptin:_RimPower,varname:_RimPower,prsc:0,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0.5;n:type:ShaderForge.SFN_Multiply,id:99,x:33147,y:31959,varname:node_99,prsc:2|A-100-RGB,B-9696-OUT;n:type:ShaderForge.SFN_Color,id:100,x:32992,y:31828,ptovrint:False,ptlb:RimColor,ptin:_RimColor,varname:_RimColor,prsc:0,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_Tex2d,id:109,x:32971,y:32690,ptovrint:False,ptlb:E02_edge,ptin:_E02_edge,varname:_E02_edge,prsc:0,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:aab0fc9023bcebc419524f9f083d3596,ntxv:2,isnm:False|UVIN-5273-OUT;n:type:ShaderForge.SFN_Color,id:111,x:33188,y:32378,ptovrint:False,ptlb:E02_Color,ptin:_E02_Color,varname:_E02_Color,prsc:0,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_Multiply,id:113,x:33342,y:32521,varname:node_113,prsc:2|A-111-RGB,B-109-R;n:type:ShaderForge.SFN_Tex2d,id:114,x:31649,y:33628,ptovrint:False,ptlb:Alpha01,ptin:_Alpha01,varname:_Alpha01,prsc:0,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:116,x:33550,y:33480,varname:node_116,prsc:2|A-8315-OUT,B-4158-OUT;n:type:ShaderForge.SFN_ValueProperty,id:117,x:33370,y:32998,ptovrint:False,ptlb:E02_alpha,ptin:_E02_alpha,varname:_E02_alpha,prsc:0,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_ValueProperty,id:142,x:33416,y:32332,ptovrint:False,ptlb:Tex_Bright,ptin:_Tex_Bright,varname:_Tex_Bright,prsc:0,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:2;n:type:ShaderForge.SFN_Tex2d,id:7550,x:32168,y:31316,ptovrint:False,ptlb:DisE01,ptin:_DisE01,varname:_DisE01,prsc:0,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Add,id:1263,x:32512,y:31108,varname:node_1263,prsc:2|A-3196-OUT,B-4442-UVOUT;n:type:ShaderForge.SFN_Panner,id:4442,x:31979,y:31111,varname:node_4442,prsc:2,spu:0,spv:1|UVIN-118-UVOUT,DIST-9811-OUT;n:type:ShaderForge.SFN_Time,id:804,x:31565,y:31128,varname:node_804,prsc:2;n:type:ShaderForge.SFN_Multiply,id:9811,x:31760,y:31148,varname:node_9811,prsc:2|A-804-T,B-7563-OUT;n:type:ShaderForge.SFN_ValueProperty,id:7563,x:31565,y:31304,ptovrint:False,ptlb:DisE01_UVpan_Speed,ptin:_DisE01_UVpan_Speed,varname:_DisE01_UVpan_Speed,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Tex2d,id:9455,x:32421,y:32530,ptovrint:False,ptlb:DisE02,ptin:_DisE02,varname:_DisE02,prsc:0,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Add,id:5273,x:32773,y:32690,varname:node_5273,prsc:2|A-1176-OUT,B-7896-UVOUT;n:type:ShaderForge.SFN_Panner,id:7896,x:32088,y:32706,varname:node_7896,prsc:2,spu:0,spv:1|UVIN-1796-OUT,DIST-4411-OUT;n:type:ShaderForge.SFN_Time,id:802,x:31470,y:32730,varname:node_802,prsc:2;n:type:ShaderForge.SFN_Multiply,id:4411,x:31745,y:32749,varname:node_4411,prsc:2|A-802-T,B-7405-OUT;n:type:ShaderForge.SFN_ValueProperty,id:7405,x:31499,y:32951,ptovrint:False,ptlb:DisE02_UVpan_Speed,ptin:_DisE02_UVpan_Speed,varname:_DisE02_UVpan_Speed,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_TexCoord,id:7118,x:31680,y:32495,varname:node_7118,prsc:2,uv:0;n:type:ShaderForge.SFN_Multiply,id:1796,x:31900,y:32532,varname:node_1796,prsc:2|A-7118-UVOUT,B-7769-OUT;n:type:ShaderForge.SFN_Add,id:4905,x:33909,y:32501,varname:node_4905,prsc:2|A-2640-OUT,B-3716-OUT;n:type:ShaderForge.SFN_Multiply,id:3196,x:32344,y:31252,varname:node_3196,prsc:0|A-6172-OUT,B-7550-R;n:type:ShaderForge.SFN_ValueProperty,id:6172,x:32168,y:31190,ptovrint:False,ptlb:DisE01_value,ptin:_DisE01_value,varname:_DisE01_value,prsc:0,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Multiply,id:1176,x:32624,y:32530,varname:node_1176,prsc:2|A-4006-OUT,B-9455-R;n:type:ShaderForge.SFN_ValueProperty,id:4006,x:32421,y:32407,ptovrint:False,ptlb:DisE02_value,ptin:_DisE02_value,varname:_DisE02_value,prsc:0,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_ValueProperty,id:8315,x:33370,y:33439,ptovrint:False,ptlb:E01_alpha,ptin:_E01_alpha,varname:_E01_alpha,prsc:0,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Multiply,id:8618,x:33519,y:33060,varname:node_8618,prsc:2|A-117-OUT,B-4034-OUT;n:type:ShaderForge.SFN_Add,id:8643,x:33828,y:33053,varname:node_8643,prsc:2|A-8618-OUT,B-116-OUT;n:type:ShaderForge.SFN_Subtract,id:4034,x:32640,y:33577,varname:node_4034,prsc:2|A-7769-OUT,B-4158-OUT;n:type:ShaderForge.SFN_Multiply,id:1822,x:33102,y:31209,varname:node_1822,prsc:0|A-7217-OUT,B-4158-OUT;n:type:ShaderForge.SFN_Tex2d,id:6868,x:31412,y:33909,ptovrint:False,ptlb:Alpha02,ptin:_Alpha02,varname:_Alpha02,prsc:0,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:7769,x:31836,y:33796,varname:node_7769,prsc:0|A-114-R,B-6868-R;n:type:ShaderForge.SFN_Multiply,id:5339,x:33493,y:32673,varname:node_5339,prsc:2|A-113-OUT,B-4322-OUT;n:type:ShaderForge.SFN_OneMinus,id:4322,x:33318,y:32833,varname:node_4322,prsc:2|IN-4158-OUT;n:type:ShaderForge.SFN_Power,id:4158,x:32007,y:33584,varname:node_4158,prsc:0|VAL-7769-OUT,EXP-9437-OUT;n:type:ShaderForge.SFN_Slider,id:9437,x:31556,y:33378,ptovrint:False,ptlb:Edge_Size,ptin:_Edge_Size,varname:_Edge_Size,prsc:0,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:6,max:6;n:type:ShaderForge.SFN_Color,id:7515,x:34311,y:31085,ptovrint:False,ptlb:Specular_Color,ptin:_Specular_Color,varname:_Specular_Color,prsc:0,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_Multiply,id:9357,x:34470,y:31273,varname:node_9357,prsc:2|A-7515-RGB,B-3488-OUT;n:type:ShaderForge.SFN_Tex2d,id:9468,x:32705,y:31361,ptovrint:False,ptlb:E01_wave02,ptin:_E01_wave02,varname:_E01_wave02,prsc:0,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:6d18dc0813cd61f4781b983c46b4ac19,ntxv:0,isnm:False|UVIN-2383-OUT;n:type:ShaderForge.SFN_Rotator,id:118,x:31813,y:30810,varname:node_118,prsc:0|UVIN-9720-UVOUT,ANG-4913-OUT;n:type:ShaderForge.SFN_ValueProperty,id:5701,x:31276,y:30883,ptovrint:False,ptlb:Wave01_UVangle,ptin:_Wave01_UVangle,varname:_Wave01_UVangle,prsc:0,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Pi,id:2588,x:31495,y:30720,varname:node_2588,prsc:2;n:type:ShaderForge.SFN_Multiply,id:4913,x:31642,y:30851,varname:node_4913,prsc:2|A-2588-OUT,B-5701-OUT;n:type:ShaderForge.SFN_Rotator,id:2707,x:31819,y:31467,varname:node_2707,prsc:0|UVIN-3058-UVOUT,ANG-2135-OUT;n:type:ShaderForge.SFN_ValueProperty,id:2607,x:31276,y:31543,ptovrint:False,ptlb:Wave02_UVangle,ptin:_Wave02_UVangle,varname:_Wave02_UVangle,prsc:0,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0;n:type:ShaderForge.SFN_Pi,id:8248,x:31490,y:31429,varname:node_8248,prsc:2;n:type:ShaderForge.SFN_Multiply,id:2135,x:31649,y:31507,varname:node_2135,prsc:2|A-8248-OUT,B-2607-OUT;n:type:ShaderForge.SFN_Panner,id:8415,x:32011,y:31436,varname:node_8415,prsc:2,spu:0,spv:1|UVIN-2707-UVOUT,DIST-9811-OUT;n:type:ShaderForge.SFN_Add,id:2383,x:32495,y:31412,varname:node_2383,prsc:2|A-3196-OUT,B-8415-UVOUT;n:type:ShaderForge.SFN_Add,id:7217,x:32880,y:31209,varname:node_7217,prsc:2|A-2-RGB,B-9468-RGB;n:type:ShaderForge.SFN_VertexColor,id:2486,x:34078,y:32727,varname:node_2486,prsc:2;n:type:ShaderForge.SFN_Multiply,id:850,x:34389,y:32503,varname:node_850,prsc:2|A-2420-OUT,B-2486-RGB;n:type:ShaderForge.SFN_Multiply,id:9084,x:34360,y:32829,varname:node_9084,prsc:2|A-2486-A,B-8643-OUT;n:type:ShaderForge.SFN_OneMinus,id:9696,x:32925,y:31977,varname:node_9696,prsc:2|IN-139-OUT;n:type:ShaderForge.SFN_RemapRange,id:139,x:32763,y:31977,varname:node_139,prsc:2,frmn:0,frmx:1,tomn:-3,tomx:3|IN-94-OUT;n:type:ShaderForge.SFN_TexCoord,id:9720,x:31642,y:30701,varname:node_9720,prsc:2,uv:0;n:type:ShaderForge.SFN_TexCoord,id:3058,x:31605,y:31660,varname:node_3058,prsc:2,uv:0;n:type:ShaderForge.SFN_Multiply,id:2640,x:33747,y:32060,varname:node_2640,prsc:2|A-7819-OUT,B-142-OUT;n:type:ShaderForge.SFN_Multiply,id:3716,x:33693,y:32656,varname:node_3716,prsc:2|A-142-OUT,B-5339-OUT;n:type:ShaderForge.SFN_Power,id:2420,x:34208,y:32503,varname:node_2420,prsc:2|VAL-4905-OUT,EXP-7720-OUT;n:type:ShaderForge.SFN_ValueProperty,id:7720,x:34045,y:32408,ptovrint:False,ptlb:Tex_Power,ptin:_Tex_Power,varname:_Tex_Power,prsc:0,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:1;n:type:ShaderForge.SFN_Clamp01,id:704,x:33329,y:31959,varname:node_704,prsc:2|IN-99-OUT;n:type:ShaderForge.SFN_If,id:8869,x:33998,y:31292,varname:node_8869,prsc:2|A-1822-OUT,B-6723-OUT,GT-739-OUT,EQ-739-OUT,LT-1850-OUT;n:type:ShaderForge.SFN_Vector1,id:739,x:33767,y:31405,varname:node_739,prsc:0,v1:1;n:type:ShaderForge.SFN_Vector1,id:1850,x:33767,y:31499,varname:node_1850,prsc:2,v1:0;n:type:ShaderForge.SFN_Slider,id:6723,x:33495,y:31360,ptovrint:False,ptlb:Specular_range,ptin:_Specular_range,varname:_Specular_range,prsc:0,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0.5,cur:1,max:2;n:type:ShaderForge.SFN_RemapRange,id:3488,x:34172,y:31292,varname:node_3488,prsc:2,frmn:0,frmx:1,tomn:0,tomx:4|IN-8869-OUT;n:type:ShaderForge.SFN_Add,id:7819,x:33512,y:31882,varname:node_7819,prsc:2|A-4-OUT,B-704-OUT;proporder:7720-142-2-9468-3-7550-6172-7563-5701-2607-8315-109-111-9455-4006-7405-117-114-6868-9437-100-98-6723-7515;pass:END;sub:END;*/

Shader "yh/ocean" {
    Properties {
        _Tex_Power ("Tex_Power", Float ) = 1
        _Tex_Bright ("Tex_Bright", Float ) = 2
        _E01_wave01 ("E01_wave01", 2D) = "white" {}
        _E01_wave02 ("E01_wave02", 2D) = "white" {}
        _E01_Color ("E01_Color", Color) = (1,1,1,1)
        _DisE01 ("DisE01", 2D) = "white" {}
        _DisE01_value ("DisE01_value", Float ) = 0
        _DisE01_UVpan_Speed ("DisE01_UVpan_Speed", Float ) = 0
        _Wave01_UVangle ("Wave01_UVangle", Float ) = 0
        _Wave02_UVangle ("Wave02_UVangle", Float ) = 0
        _E01_alpha ("E01_alpha", Float ) = 1
        _E02_edge ("E02_edge", 2D) = "black" {}
        _E02_Color ("E02_Color", Color) = (1,1,1,1)
        _DisE02 ("DisE02", 2D) = "white" {}
        _DisE02_value ("DisE02_value", Float ) = 1
        _DisE02_UVpan_Speed ("DisE02_UVpan_Speed", Float ) = 1
        _E02_alpha ("E02_alpha", Float ) = 1
        _Alpha01 ("Alpha01", 2D) = "white" {}
        _Alpha02 ("Alpha02", 2D) = "white" {}
        _Edge_Size ("Edge_Size", Range(0, 6)) = 6
        _RimColor ("RimColor", Color) = (1,1,1,1)
        _RimPower ("RimPower", Float ) = 0.5
        _Specular_range ("Specular_range", Range(0.5, 2)) = 1
        _Specular_Color ("Specular_Color", Color) = (1,1,1,1)
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader {
        Tags {
            "Queue"="Transparent-1"
            "RenderType"="Transparent"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile_fog
            #pragma exclude_renderers xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
            uniform float4 _TimeEditor;
            uniform sampler2D _E01_wave01; uniform float4 _E01_wave01_ST;
            uniform fixed4 _E01_Color;
            uniform fixed _RimPower;
            uniform fixed4 _RimColor;
            uniform sampler2D _E02_edge; uniform float4 _E02_edge_ST;
            uniform fixed4 _E02_Color;
            uniform sampler2D _Alpha01; uniform float4 _Alpha01_ST;
            uniform fixed _E02_alpha;
            uniform fixed _Tex_Bright;
            uniform sampler2D _DisE01; uniform float4 _DisE01_ST;
            uniform float _DisE01_UVpan_Speed;
            uniform sampler2D _DisE02; uniform float4 _DisE02_ST;
            uniform float _DisE02_UVpan_Speed;
            uniform fixed _DisE01_value;
            uniform fixed _DisE02_value;
            uniform fixed _E01_alpha;
            uniform sampler2D _Alpha02; uniform float4 _Alpha02_ST;
            uniform fixed _Edge_Size;
            uniform fixed4 _Specular_Color;
            uniform sampler2D _E01_wave02; uniform float4 _E01_wave02_ST;
            uniform fixed _Wave01_UVangle;
            uniform fixed _Wave02_UVangle;
            uniform fixed _Tex_Power;
            uniform fixed _Specular_range;
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
                UNITY_FOG_COORDS(3)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos(v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
////// Lighting:
////// Emissive:
                fixed4 _DisE01_var = tex2D(_DisE01,TRANSFORM_TEX(i.uv0, _DisE01));
                fixed node_3196 = (_DisE01_value*_DisE01_var.r);
                float4 node_804 = _Time + _TimeEditor;
                float node_9811 = (node_804.g*_DisE01_UVpan_Speed);
                float node_118_ang = (3.141592654*_Wave01_UVangle);
                float node_118_spd = 1.0;
                float node_118_cos = cos(node_118_spd*node_118_ang);
                float node_118_sin = sin(node_118_spd*node_118_ang);
                float2 node_118_piv = float2(0.5,0.5);
                fixed2 node_118 = (mul(i.uv0-node_118_piv,float2x2( node_118_cos, -node_118_sin, node_118_sin, node_118_cos))+node_118_piv);
                float2 node_1263 = (node_3196+(node_118+node_9811*float2(0,1)));
                fixed4 _E01_wave01_var = tex2D(_E01_wave01,TRANSFORM_TEX(node_1263, _E01_wave01));
                float node_2707_ang = (3.141592654*_Wave02_UVangle);
                float node_2707_spd = 1.0;
                float node_2707_cos = cos(node_2707_spd*node_2707_ang);
                float node_2707_sin = sin(node_2707_spd*node_2707_ang);
                float2 node_2707_piv = float2(0.5,0.5);
                fixed2 node_2707 = (mul(i.uv0-node_2707_piv,float2x2( node_2707_cos, -node_2707_sin, node_2707_sin, node_2707_cos))+node_2707_piv);
                float2 node_2383 = (node_3196+(node_2707+node_9811*float2(0,1)));
                fixed4 _E01_wave02_var = tex2D(_E01_wave02,TRANSFORM_TEX(node_2383, _E01_wave02));
                fixed4 _Alpha01_var = tex2D(_Alpha01,TRANSFORM_TEX(i.uv0, _Alpha01));
                fixed4 _Alpha02_var = tex2D(_Alpha02,TRANSFORM_TEX(i.uv0, _Alpha02));
                fixed node_7769 = (_Alpha01_var.r*_Alpha02_var.r);
                fixed node_4158 = pow(node_7769,_Edge_Size);
                fixed3 node_1822 = ((_E01_wave01_var.rgb+_E01_wave02_var.rgb)*node_4158);
                fixed4 _DisE02_var = tex2D(_DisE02,TRANSFORM_TEX(i.uv0, _DisE02));
                float4 node_802 = _Time + _TimeEditor;
                float2 node_5273 = ((_DisE02_value*_DisE02_var.r)+((i.uv0*node_7769)+(node_802.g*_DisE02_UVpan_Speed)*float2(0,1)));
                fixed4 _E02_edge_var = tex2D(_E02_edge,TRANSFORM_TEX(node_5273, _E02_edge));
                float3 emissive = (pow(((((_E01_Color.rgb*node_1822)+saturate((_RimColor.rgb*(1.0 - (pow(1.0-max(0,dot(normalDirection, viewDirection)),_RimPower)*6.0+-3.0)))))*_Tex_Bright)+(_Tex_Bright*((_E02_Color.rgb*_E02_edge_var.r)*(1.0 - node_4158)))),_Tex_Power)*i.vertexColor.rgb);
                float node_8869_if_leA = step(node_1822,_Specular_range);
                float node_8869_if_leB = step(_Specular_range,node_1822);
                fixed node_739 = 1.0;
                float3 finalColor = emissive + (_Specular_Color.rgb*(lerp((node_8869_if_leA*0.0)+(node_8869_if_leB*node_739),node_739,node_8869_if_leA*node_8869_if_leB)*4.0+0.0));
                fixed4 finalRGBA = fixed4(finalColor,(i.vertexColor.a*((_E02_alpha*(node_7769-node_4158))+(_E01_alpha*node_4158))));
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
