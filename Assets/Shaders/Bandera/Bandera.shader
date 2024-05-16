Shader "Unlit/Bandera"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1.0,1.0,1.0)
        _WindDirection("Wind Direction", Vector) = (1, 0, 0, 0) // Dirección del viento
        _Speed("Speed", Range(0, 10)) = 1
        _WaveHeight("Wave Height", Range(0, 1)) = 0.1
        _WaveFrequency("Wave Frequency", Range(0, 10)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        
        Pass
        {
            Cull off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal: NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 col: COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float2 _WindDirection;
            float _Speed;
            float _WaveHeight;
            float _WaveFrequency;
            // user defined variables
            uniform float4 _Color;

            // unity defined variables
            uniform float4 _LightColor0;
            v2f vert (appdata v)
            {
                v2f o;
                float3 normalDirection = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
                float3 lightDirection;
                float atten = 1.0;

                lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 diffuseReflection = atten * _LightColor0.xyz * max(0.0, dot(normalDirection, lightDirection));
                float3 lightFinal = diffuseReflection + UNITY_LIGHTMODEL_AMBIENT.xyz;

                o.col = float4(lightFinal * _Color.rgb, 1.0);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.vertex = UnityObjectToClipPos(v.vertex);

                float windOffset = sin(_Time.y * _WaveFrequency + v.uv.x) * _WaveHeight;
                float2 offset = _WindDirection * windOffset;
                // Deformar el plano en la dirección perpendicular a la superficie

                o.vertex = UnityObjectToClipPos(v.vertex + float4(offset, 0, 0));
                float waveOffset = sin(_Time.y * _Speed + v.uv.x * _WaveFrequency) * _WaveHeight;
                o.vertex.y += waveOffset;
                o.uv = v.uv;
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                UNITY_APPLY_FOG(i.fogCoord, col);
                return i.col * col;
            }
            ENDCG
        }
    }
}
