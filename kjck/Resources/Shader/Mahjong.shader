// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Mahjong/Mahjong" {
	Properties 
	{
		_Color ("Main Color", Color) = (0,0,0,1)
		_SpecColor ("Specular Color", Color) = (0.5,0.5,0.5,1)
		_LightDir ("LightDir", Vector) = (0.5,0.5,0.5,1)
		_LightDir1 ("LightDir1", Vector) = (0.5,0.5,0.5,1)
		_Shininess ("Shininess", Range(0.01,50)) = 0.078125
		_Emission ("Emission", Range(0.01,1)) = 0.3
		_Intensity ("Intensity", Float) = 1
		_MainTex ("Base (RGB) RefStrGloss (A)", 2D) = "white" {}
		//_Mask ("MaskTexture", 2D) = "white" {}
	}
	SubShader 
	{
		Pass 
		{
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
				float2 texcoord : TEXCOORD0;
				float3 normal : NORMAL;
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
				half3 tem1 = normalize((_LightDir - mul(unity_ObjectToWorld , v.vertex).xyz));
				float tmp2 = rsqrt(dot (tem1, tem1));
				half3 tmp3 = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);

				half3 lightDir = normalize(_LightDir1);
				fixed3 ambientLighting = (UNITY_LIGHTMODEL_AMBIENT.xyz * _Color.xyz);
				half4 light = half4(ambientLighting + ((rsqrt(dot(lightDir, lightDir))* _Color.xyz) * max(0.0, dot (normalize(tmp3), lightDir))), 1.0);

				o.vertex = mul(UNITY_MATRIX_MVP , v.vertex);
				o.texcoord = v.texcoord.xy;
				o.texcoord1 = tmp3;
				o.texcoord2 = tem1;
				o.texcoord3 = clamp (light, half4(0.0, 0.0, 0.0, 0.0), half4(1.0, 1.0, 1.0, 1.0));
				o.texcoord4 = tmp2;

				return o;
			}
				
			fixed4 frag (v2f IN) : COLOR
			{
				half3 specularReflection = normalize(IN.texcoord1);

				half3 I = -IN.texcoord2;

				specularReflection = ((IN.texcoord4 * _SpecColor.xyz) * pow(max(0.0, dot((I - (2.0 * (dot (specularReflection, I) * specularReflection))), specularReflection)), _Shininess));

				fixed4 specularCol = fixed4(specularReflection,1.0);

				fixed4 temp=tex2D(_MainTex, IN.texcoord);

				return ((((temp * IN.texcoord3)* _Intensity) + specularCol) + (temp * _Emission));
			}

			ENDCG
		}
	} 
	FallBack "Unlit/Texture"
}
