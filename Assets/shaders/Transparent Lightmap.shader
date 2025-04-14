// Unlit shader. Simplest possible textured shader.
// - no lighting
// - no lightmap support
// - no per-material color

Shader "Custom/Transparent Lightmap" {
Properties {
	_LightFactor ("Light factor", Range (0.5, 2)) = 1
	_MainTex ("Base (RGBA)", 2D) = "white" {}
	_LighMap ("LightMap (RGB)", 2D) = "white" {}
}

SubShader {

    Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
    LOD 200

    Lighting Off
    ZWrite Off
    //Offset -1, -1
    Blend SrcAlpha OneMinusSrcAlpha 
    
    CGPROGRAM
    #pragma surface surf Lambert alpha

    sampler2D _MainTex;
    sampler2D _LighMap;
    float _LightFactor;

    struct Input {
        half2 uv_MainTex;
        half2 uv2_LighMap;
    };

    
    void surf (Input IN, inout SurfaceOutput o) {
        fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
        fixed4 l = tex2D(_LighMap, IN.uv2_LighMap) * _LightFactor;
        o.Albedo = c.rgb * l.rgb;
        o.Alpha = c.a;
    }
    ENDCG
}

}
