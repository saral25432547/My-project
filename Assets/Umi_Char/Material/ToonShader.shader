Shader "Supyrb/Unlit/TextureAlphaMask"
{
    Properties
    {
        [HDR]_Color("Albedo", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _AlphaTex ("Alpha Mask", 2D) = "white" {}
        
        [Toggle] _UseRoughness ("Use Roughness", Float) = 0
        _Roughness ("Roughness", Range(0,1)) = 0.5
        _RoughnessTex ("Roughness Texture", 2D) = "white" {}
        
        [Toggle] _UseMetallic ("Use Metallic", Float) = 0
        _Metallic ("Metallic", Range(0,1)) = 0.5
        _MetallicTex ("Metallic Texture", 2D) = "white" {}
        
        [Toggle] _UseNormal ("Use Normal Map", Float) = 0
        _NormalTex ("Normal Map", 2D) = "bump" {}
        _NormalStrength ("Normal Strength", Range(0,2)) = 1
    }
   
    CGINCLUDE
    #include "UnityCG.cginc"
 
    half4 _Color;
    sampler2D _MainTex, _AlphaTex, _RoughnessTex, _MetallicTex, _NormalTex;
    float _Roughness, _Metallic, _UseRoughness, _UseMetallic, _UseNormal, _NormalStrength;
    
    struct appdata
    {
        float4 vertex : POSITION;
        float3 normal : NORMAL;
        float2 uv : TEXCOORD0;
        float4 tangent : TANGENT;
    };
 
    struct v2f
    {
        float2 uv : TEXCOORD0;
        float4 vertex : SV_POSITION;
        float3 normal : TEXCOORD1;
        float3 tangent : TEXCOORD2;
        float3 bitangent : TEXCOORD3;
    };
 
    v2f vert (appdata v)
    {
        v2f o;
        o.vertex = UnityObjectToClipPos(v.vertex);
        o.uv = v.uv;
        o.normal = UnityObjectToWorldNormal(v.normal);
        o.tangent = UnityObjectToWorldDir(v.tangent.xyz);
        o.bitangent = cross(o.normal, o.tangent) * v.tangent.w;
        return o;
    }
   
    half4 frag (v2f i) : SV_Target
    {
        half4 col = tex2D(_MainTex, i.uv) * _Color;
        half alpha = tex2D(_AlphaTex, i.uv).r;
        col.a *= alpha;
        
        clip(col.a - 0.1); // ใช้ Alpha Clipping แทน Transparency
        
        if (_UseRoughness > 0.5)
            col.rgb *= tex2D(_RoughnessTex, i.uv).r * _Roughness;
        
        if (_UseMetallic > 0.5)
            col.rgb *= tex2D(_MetallicTex, i.uv).r * _Metallic;
        
        if (_UseNormal > 0.5)
        {
            half3 normalMap = UnpackNormal(tex2D(_NormalTex, i.uv));
            normalMap.xy *= _NormalStrength;
            normalMap.z = sqrt(saturate(1.0 - dot(normalMap.xy, normalMap.xy)));
            half3x3 TBN = half3x3(normalize(i.tangent), normalize(i.bitangent), normalize(i.normal));
            half3 normalWS = normalize(mul(TBN, normalMap));
            half3 lightDir = normalize(float3(0.5, 0.5, 1));
            half diffuse = saturate(dot(normalWS, lightDir));
            col.rgb = lerp(col.rgb, col.rgb * diffuse, _NormalStrength);
        }
        
        return col;
    }
    
    struct v2fShadow {
        V2F_SHADOW_CASTER;
        UNITY_VERTEX_OUTPUT_STEREO
    };
 
    v2fShadow vertShadow( appdata_base v )
    {
        v2fShadow o;
        UNITY_SETUP_INSTANCE_ID(v);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
        TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
        return o;
    }
 
    float4 fragShadow( v2fShadow i ) : SV_Target
    {
        SHADOW_CASTER_FRAGMENT(i)
    }
   
    ENDCG
       
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="AlphaTest" }
        Blend One OneMinusSrcAlpha // ใช้ Alpha Clipping แทน Transparency
        ZWrite On // ป้องกันปัญหามองทะลุ
        Cull Back // ซ่อนด้านในของโมเดล
       
        Pass
        {
            Tags { "RenderType"="Opaque" }
            LOD 100
            ZTest LEqual
            
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }
        
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode"="ShadowCaster" }
            ZWrite On
            ZTest LEqual
            ColorMask 0
            
            CGPROGRAM
            #pragma vertex vertShadow
            #pragma fragment fragShadow
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"
            ENDCG
        }
    }
}