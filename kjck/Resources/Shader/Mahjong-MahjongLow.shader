Shader "Mahjong/MahjongLow" 
{
	Properties 
	{
		_Color ("Main Color", Color) = (0,0,0,1)
		_MainTex ("Base (RGB) RefStrGloss (A)", 2D) = "white" {}
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

			struct appdata_t
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 texcoord : TEXCOORD0;
			};

			v2f o;

			v2f vert (appdata_t v)
			{
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.texcoord = v.texcoord;
				return o;
			}

			fixed4 frag (v2f IN) : COLOR
			{
				return tex2D(_MainTex, IN.texcoord) * _Color;
			}

			ENDCG
		}
	} 
	FallBack "Unlit/Texture"
}