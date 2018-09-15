Shader "Mahjong/Hand1" 
{
	Properties 
	{
		_MainTex ("Base (RGB) RefStrGloss (A)", 2D) = "white" {}
		_TatoTex ("TatoTex", 2D) = "white" {}
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
			sampler2D _TatoTex;

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
				o.vertex = mul(UNITY_MATRIX_MVP , v.vertex);
				o.texcoord = v.texcoord;
				return o;
			}

			fixed4 frag (v2f IN) : COLOR
			{
				fixed4 tex = tex2D (_MainTex, IN.texcoord.xy);
				fixed4 tato = tex2D (_TatoTex, IN.texcoord.xy);
				fixed4 mainColor = fixed4(tex.xyz * (tato.xyz * tato.w), tex.w);

				return mainColor;
			}

			ENDCG
		}
	} 
	FallBack "Unlit/Texture"
}