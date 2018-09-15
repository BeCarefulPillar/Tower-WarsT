Shader "Unlit/NGUI Particle Add" 
{
	Properties 
	{
		_Color ("Color", Color) = (1.0,1.0,1.0,1.0)
		_MainTex ("Base (RGB), Alpha (A)", 2D) = "black" {}
	}
	Category 
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }

		Cull Off 
		Lighting Off 
		ZWrite Off 

		Blend SrcAlpha One
	
		SubShader 
		{
			LOD 200

			Pass 
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"

				float4 _Color;
				sampler2D _MainTex;
				float4 _MainTex_ST;
	
				struct appdata_t
				{
					float4 vertex : POSITION;
					float2 texcoord : TEXCOORD0;
					fixed4 color : COLOR;
				};
	
				struct v2f
				{
					float4 vertex : SV_POSITION;
					half2 texcoord : TEXCOORD0;
					fixed4 color : COLOR;
				};
	
				v2f o;

				v2f vert (appdata_t v)
				{
					o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
					o.texcoord = v.texcoord;
					o.color = v.color;
					return o;
				}
				
				fixed4 frag (v2f IN) : COLOR
				{
					fixed4 col = tex2D(_MainTex, IN.texcoord) * IN.color * _Color;
					return col;
				}
				ENDCG
			}
		}

		SubShader
		{
			LOD 100
		
			Pass
			{
				ColorMask RGB
				Blend SrcAlpha OneMinusSrcAlpha
				ColorMaterial AmbientAndDiffuse
			
				SetTexture [_MainTex] { combine texture * primary }
			}
		}
	}
}