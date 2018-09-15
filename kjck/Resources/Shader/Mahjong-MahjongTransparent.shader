// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Mahjong/MahjongTransparent" 
{
	Properties 
	{
		_Color ("Main Color", Color) = (0,0,0,1)
		_SpecColor ("Specular Color", Color) = (0.5,0.5,0.5,1)
		_LightDir ("LightDir", Vector) = (0.5,0.5,0.5,1)
		_LightDir1 ("LightDir1", Vector) = (0.5,0.5,0.5,1)
		_Shininess ("Shininess", Range(0.01,50)) = 0.078125
		_Emission ("Emission", Range(0.01,1)) = 0.3
		_Intensity ("_Intensity", Float) = 1
		_MainTex ("Base (RGB) RefStrGloss (A)", 2D) = "white" {}
		_Mask ("MaskTexture", 2D) = "white" {}
	}

	SubShader 
	{ 
		Tags { "QUEUE"="Transparent" "RenderType"="Transparent" }
		Pass 
		{
			Tags { "QUEUE"="Transparent" "RenderType"="Transparent" }
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			fixed4 _Color;
			fixed3 _LightDir;
			fixed3 _LightDir1;
			fixed4 _SpecColor;
			half _Shininess;
			half _Emission;
			half _Intensity;

			struct appdata_t
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 texcoord : TEXCOORD0;
				half3 texcoord1 : TEXCOORD1;
				half3 texcoord2 : TEXCOORD2;
				half4 texcoord3 : TEXCOORD3;
				float texcoord4 : TEXCOORD4;
			};

			v2f o;

			v2f vert (appdata_t v)
			{
				fixed3 ambientLighting;
				half3 lightDir;
				half3 tmp3;
				half3 tmp4;
				float tmp5;

				float4 tmp6 = float4(v.normal, 0.0);

				float3 tmp7 = normalize(mul(tmp6, unity_WorldToObject).xyz);

				tmp3 = tmp7;

				float3 tmp8 = normalize((_LightDir - mul(unity_ObjectToWorld, v.vertex).xyz));

				tmp4 = tmp8;

				fixed3 tmp9 = normalize(_LightDir1);

				lightDir = tmp9;

				float3 tmp10 = (UNITY_LIGHTMODEL_AMBIENT.xyz * _Color.xyz);

				ambientLighting = tmp10;

				half4 tmp11 = half4(ambientLighting + ((rsqrt(dot (lightDir, lightDir)) * _Color.xyz) * max(0.0, dot(normalize(tmp3), lightDir))), 1.0);

				half tmp12 = rsqrt(dot(tmp4, tmp4));

				tmp5 = tmp12;

				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.texcoord = v.texcoord;
				o.texcoord1 = tmp3;
				o.texcoord2 = tmp4;
				o.texcoord3 = clamp (tmp11, float4(0.0, 0.0, 0.0, 0.0), float4(1.0, 1.0, 1.0, 1.0));
				o.texcoord4 = tmp5;

				return o;
			}

			fixed4 frag (v2f IN) : COLOR
			{
				fixed4 color;
				fixed4 specularCol;
				half3 specularReflection;
				half3 tmp4 = normalize(IN.texcoord1);
				half3 I = -IN.texcoord2;
				half tmp6 = pow(max(0.0, dot((I - (2.0 * (dot(tmp4, I) * tmp4))), tmp4)), _Shininess);
				float3 tmp7 = ((IN.texcoord4 * _SpecColor.xyz) * tmp6);
				specularReflection = tmp7;
				half4 tmp8 = half4(specularReflection, 1.0);
				specularCol = tmp8;
				fixed4 tmp9 = tex2D(_MainTex, IN.texcoord);
				half4 tmp10  = ((((tmp9 * IN.texcoord3) * _Intensity) + specularCol) + (tmp9 * _Emission));
				color.xyz = tmp10.xyz;
				color.w = _Color.w;
				return color;
			}

			ENDCG
		}
	} 
	FallBack "Unlit/Texture"
}