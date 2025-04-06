Shader "Custom/FadeBarrier"
{
    Properties
    {
        _Color ("Color", Color) = (0, 0.5, 1, 1)
        _EdgeColor ("Edge Color", Color) = (1,1,1,1)
        _FadeDistance ("Fade Distance", Range(1, 20)) = 10
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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
            };

            float4 _Color;
            float4 _EdgeColor;
            float3 _PlayerPosition;
            float _FadeDistance;
            float _EdgeWidth;

            v2f vert (appdata_t v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float dist = distance(i.worldPos, _PlayerPosition);
                
                // คำนวณความโปร่งใสโดยใช้ระยะห่าง
                float alpha = saturate(1 - (dist / _FadeDistance));

                // Fresnel Effect ทำให้ขอบสว่างขึ้น
                float fresnel = dot(normalize(i.worldNormal), normalize(i.worldPos - _PlayerPosition));
                fresnel = pow(1 - fresnel, _EdgeWidth);

                // ผสมสีระหว่างตัวบาเรียกับขอบ
                fixed4 col = lerp(_Color, _EdgeColor, fresnel);
                col.a *= alpha; // ใช้ค่าโปร่งใส

                return col;
            }
            ENDCG
        }
    }
}
