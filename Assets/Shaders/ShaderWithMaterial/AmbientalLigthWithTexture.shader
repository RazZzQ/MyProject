Shader "Unlit/AmbientalLigthWithTexture"
{
	Properties{
		_MainTex("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1.0,1.0,1.0)
	}

		SubShader{
			Tags {"LightMode" = "ForwardBase"}
			Pass{

				CGPROGRAM

				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_fog
				#include "UnityCG.cginc"
				// base input structs
				struct vertexInput {
					float4 vertex: POSITION;
					float3 normal: NORMAL;
					float2 uv : TEXCOORD0;
				};
				struct vertexOutput {
					float2 uv : TEXCOORD0;
					UNITY_FOG_COORDS(1)
					float4 pos: SV_POSITION;
					float4 col: COLOR;
				};
				sampler2D _MainTex;
				float4 _MainTex_ST;
				// user defined variables
				uniform float4 _Color;

				// unity defined variables
				uniform float4 _LightColor0;
				// vertex functions
				vertexOutput vert(vertexInput v) {
					vertexOutput o;

					float3 normalDirection = normalize(mul(float4(v.normal, 0.0),unity_WorldToObject).xyz);
					float3 lightDirection;
					float atten = 1.0;

					lightDirection = normalize(_WorldSpaceLightPos0.xyz);
					float3 diffuseReflection = atten * _LightColor0.xyz * max(0.0,dot(normalDirection, lightDirection));
					float3 lightFinal = diffuseReflection + UNITY_LIGHTMODEL_AMBIENT.xyz;

					o.col = float4(lightFinal * _Color.rgb, 1.0);
					o.pos = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);
					UNITY_TRANSFER_FOG(o, o.vertex);

					return o;
				}
				// fragment function
				float4 frag(vertexOutput i) : COLOR
				{
					fixed4 col = tex2D(_MainTex, i.uv);
					return i.col * col;
				}
			ENDCG
			}
			// fallback commentd out during development
			// fallback "Diffuse"
		}
}
