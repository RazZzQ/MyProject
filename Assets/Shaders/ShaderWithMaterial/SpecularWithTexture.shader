Shader "Unlit/SpecularWithTexture"
{
    Properties{
       _MainTex("Texture", 2D) = "white" {}
       _Color("Diffuse Material Color", Color) = (1,1,1,1)
       _SpecColor("Specular Material Color", Color) = (1,1,1,1)
       _Shininess("Shininess", Float) = 10
    }
        SubShader{
           Pass {
              Tags { "LightMode" = "ForwardBase" }
              // pass for ambient light and first light source

              CGPROGRAM

              #pragma vertex vert  
              #pragma fragment frag 
              #pragma multi_compile_fog
              #include "UnityCG.cginc"
               uniform float4 _LightColor0;
                // color of light source (from "Lighting.cginc")

                // User-specified properties
                uniform float4 _Color;
                uniform float4 _SpecColor;
                uniform float _Shininess;

                struct vertexInput {
                   float4 vertex : POSITION;
                   float3 normal : NORMAL;
                   float2 uv : TEXCOORD0;
                };
                struct vertexOutput {
                   float2 uv : TEXCOORD0;
                   UNITY_FOG_COORDS(1)
                   float4 pos : SV_POSITION;
                   float4 col : COLOR;
                };
                sampler2D _MainTex;
                float4 _MainTex_ST;
             vertexOutput vert(vertexInput input)
             {
                vertexOutput output;

                float4x4 modelMatrix = unity_ObjectToWorld;
                float3x3 modelMatrixInverse = unity_WorldToObject;
                float3 normalDirection = normalize(
                   mul(input.normal, modelMatrixInverse));
                float3 viewDirection = normalize(_WorldSpaceCameraPos
                   - mul(modelMatrix, input.vertex).xyz);
                float3 lightDirection;
                float attenuation;

                if (0.0 == _WorldSpaceLightPos0.w) // directional light?
                {
                   attenuation = 1.0; // no attenuation
                   lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                }
                else // point or spot light
                {
                   float3 vertexToLightSource = _WorldSpaceLightPos0.xyz
                      - mul(modelMatrix, input.vertex).xyz;
                   float distance = length(vertexToLightSource);
                   attenuation = 1.0 / distance; // linear attenuation 
                   lightDirection = normalize(vertexToLightSource);
                }

                float3 ambientLighting =
                   UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;

                float3 diffuseReflection =
                   attenuation * _LightColor0.rgb * _Color.rgb
                   * max(0.0, dot(normalDirection, lightDirection));

                float3 specularReflection;
                if (dot(normalDirection, lightDirection) < 0.0)
                    // light source on the wrong side?
                {
                    specularReflection = float3(0.0, 0.0, 0.0);
                    // no specular reflection
                }
                else // light source on the right side
                {
                    specularReflection = attenuation * _LightColor0.rgb
                    * _SpecColor.rgb * pow(max(0.0, dot(
                    reflect(-lightDirection, normalDirection),
                    viewDirection)), _Shininess);
                }

                  output.col = float4(ambientLighting + diffuseReflection
                     + specularReflection, 1.0);
                  output.pos = UnityObjectToClipPos(input.vertex);
                  output.uv = TRANSFORM_TEX(input.uv, _MainTex);
                  UNITY_TRANSFER_FOG(output, output.vertex);
                  return output;
                }
             
                float4 frag(vertexOutput input) : COLOR
                {
                   fixed4 col = tex2D(_MainTex, input.uv);

                   return input.col * col;
                }

            ENDCG
           }

        }
        Fallback "Specular"
}
