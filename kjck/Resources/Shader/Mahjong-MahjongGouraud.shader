// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Mahjong/MahjongGouraud" 
{
	Properties 
	{
		_Color ("Main Color", Color) = (0,0,0,1)
		//_SpecColor ("Specular Color", Color) = (0.5,0.5,0.5,1)
		//_LightDir ("LightDir", Vector) = (0.5,0.5,0.5,1)
		_LightDir1 ("LightDir1", Vector) = (0.5,0.5,0.5,1)
		//_Shininess ("Shininess", Range(0.01,50)) = 0.078125
		_Emission ("Emission", Range(0.01,1)) = 0.3
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
			//fixed3 _LightDir;
			fixed3 _LightDir1;
			//fixed4 _SpecColor;
			//half _Shininess;
			half _Emission;

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
				fixed4 texcoord1 : TEXCOORD1;
			};

			v2f o;

			v2f vert (appdata_t v)
			{
				half3 normalDir = normalize(mul(float4(v.normal,0.0), unity_WorldToObject).xyz);
				half3 ambientLighting = (UNITY_LIGHTMODEL_AMBIENT.xyz * _Color.xyz);
				fixed3 cse = normalize(_LightDir1);

				fixed4 texcoord1=clamp(half4((ambientLighting + (((1.0/(sqrt(dot(cse, cse))))* _Color.xyz) * max(0.0, dot (normalDir, cse)))),1.0), half4(0.0, 0.0, 0.0, 0.0), half4(1.0, 1.0, 1.0, 1.0));
  
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.texcoord = v.texcoord.xy;
				o.texcoord1 = texcoord1;

				return o;
			}

			fixed4 frag (v2f IN) : COLOR
			{
				return (tex2D(_MainTex, IN.texcoord) * (IN.texcoord1 + _Emission));
			}

			ENDCG
		}
	} 
	FallBack "Unlit/Texture"
}