Shader "Custom/PortalShader"
{
    Properties
    {
        _MainTex ("Render Texture", 2D) = "white" {}
        _EdgeColor ("Edge Glow Color", Color) = (0, 0.5, 1, 1)
        _EdgeWidth ("Edge Width", Range(0.1, 5)) = 1
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Back

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _EdgeColor;
            float _EdgeWidth;

            v2f vert (appdata_t v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = normalize(WorldSpaceViewDir(v.vertex));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Render Texture
                fixed4 texColor = tex2D(_MainTex, i.uv);

                // Fresnel Effect for Edge Glow
                float fresnel = dot(normalize(i.viewDir), normalize(i.worldNormal));
                fresnel = pow(1 - fresnel, _EdgeWidth);

                // Blend Edge Color
                fixed4 col = lerp(texColor, _EdgeColor, fresnel);
                return col;
            }
            ENDCG
        }
    }
}
